using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;

namespace debugger
{
	public partial class DMDBG : Form
	{

		class ProcInfoRow
		{
			public string BP { get; set; }
			public string isCurrent { get; set; }
			public int Offset { get; set; }
			public string Bytes { get; set; }
			public string Mnemonic { get; set; }
			public string Comment { get; set; }

			public ProcInfoRow(int offset, String bytes, String mnemonic, String comments)
			{
				BP = "";
				isCurrent = "";
				Offset = offset;
				Bytes = bytes;
				Mnemonic = mnemonic;
				Comment = comments;
			}
		}

		class ProcEntry
		{
			public string name;
			public List<ProcInfoRow> disassembly;
		}

		struct Message
		{
			public string type;
			public string content;
		}

		private int current_instruction = 0;

		private void send_message(string type, object content = null)
		{
			Dictionary<string, object> message = new Dictionary<string, object>();
			message["type"] = type;
			message["content"] = content;
			string msg = JsonConvert.SerializeObject(message);
			writer.Write(msg + "\n");
			writer.Flush();
		}

		public DMDBG()
		{
			InitializeComponent();
		}

		private List<string> procNames;
		private Dictionary<string, ProcEntry> procInfos;
		private NamedPipeClientStream debuggerPipeWritable;
		private NamedPipeClientStream debuggerPipeReadable;

		private StreamReader reader;
		private StreamWriter writer;

		private bool ready = false;

		private void DMDBG_Load(object sender, EventArgs e)
		{
			procNames = new List<string>();
			procInfos = new Dictionary<string, ProcEntry>();
			status.Text = "Waiting for debug adapter to start...";
			Task.Factory.StartNew(() => connect());
		}

		public void connect()
		{
			debuggerPipeWritable = new NamedPipeClientStream("DMDBGRead");
			debuggerPipeReadable = new NamedPipeClientStream("DMDBGWrite");
			debuggerPipeWritable.Connect();
			debuggerPipeReadable.Connect();
			reader = new StreamReader(debuggerPipeReadable);
			writer = new StreamWriter(debuggerPipeWritable);
			send_message("Proc list please");
			status.Text = "Receiving proc list...";
			string line = reader.ReadLine();
			//MessageBox.Show(line);
			List<string> data =
				JsonConvert.DeserializeObject<List<string>>(JsonConvert.DeserializeObject<Message>(line).content);
			data = data.OrderBy(o => o).ToList();

            if(procList.InvokeRequired)
            {
                procList.Invoke(new Action(() => update_proclist(data)));
            }
            else
            {
                update_proclist(data);
            }

			disassembly.DefaultCellStyle.SelectionForeColor = Color.Black;
			disassembly.DefaultCellStyle.SelectionBackColor = Color.LightGray;
			Task.Factory.StartNew(() => receive_data());
			status.Text = "Ready!";
			ready = true;
		}

        public void update_proclist(List<string> data)
        {
            procList.BeginUpdate();
            foreach (string name in data)
            {
                ProcEntry proc = new ProcEntry();
                proc.name = name;
                proc.disassembly = null;
                procNames.Add(name);
                procList.Items.Add(name);
                procInfos.Add(name, proc);
                //MessageBox.Show(procInfos[proc.procName].ToString());
            }

            procList.EndUpdate();
        }

		public void receive_data()
		{
			while (true)
			{
                string strMsg = reader.ReadLine();
                if (string.IsNullOrEmpty(strMsg))
                    continue;
                //MessageBox.Show("Reading");
                //writer.Write("ignore\n");
                //writer.Flush();
                Message msg = JsonConvert.DeserializeObject<Message>(strMsg);
				//MessageBox.Show(line);
				if (msg.type == "disassembly")
				{
					fuck = JsonConvert.DeserializeObject<List<ProcInfoRow>>(msg.content);
					oSignalEvent.Set();
				}

				else if (msg.type == "debugger current")
				{
					Shit shit = JsonConvert.DeserializeObject<Shit>(msg.content);
					ProcInfoRow pir = disassembly.CurrentRow.DataBoundItem as ProcInfoRow;
					if (pir != null)
					{
						pir.isCurrent = "";
					}

					int currentStep;

					ProcEntry fuckass = procInfos[shit.procname];
					for (int i = 0; i < fuckass.disassembly.Count; i++)
					{
						procInfos[shit.procname].disassembly[i].isCurrent = "";
						if (procInfos[shit.procname].disassembly[i].Offset == shit.offset)
						{
							procInfos[shit.procname].disassembly[i].isCurrent = ">";
							currentStep = i;
						}
					}

					Invoke(new Action(() =>
					{
						int hack = disassembly.FirstDisplayedScrollingRowIndex;
						int current = disassembly.CurrentRow.Index;
						BindingSource bs = new BindingSource();
						bs.DataSource = procInfos[shit.procname].disassembly;
						disassembly.DataSource = bs;
						disassembly.Rows[current].Selected = true;
						disassembly.FirstDisplayedScrollingRowIndex = hack;
					}));

				}

				else if (msg.type == "local variables" && msg.content != null)
				{
					//MessageBox.Show(msg.content);
					List<LocalVariable> locals = JsonConvert.DeserializeObject<List<LocalVariable>>(msg.content);
					Invoke(new Action(() =>
					{
						BindingSource bs = new BindingSource();
						if (locals != null)
						{
							bs.DataSource = locals;
						}
						else
						{
							bs.DataSource = new List<LocalVariable>();
						}
						localVariables.DataSource = bs;
					}));
				}

				else if (msg.type == "arguments" && msg.content != null)
				{
					//MessageBox.Show(msg.content);
					List<Argument> args = JsonConvert.DeserializeObject<List<Argument>>(msg.content);
					Invoke(new Action(() =>
					{
						BindingSource bs = new BindingSource();
						if (args != null)
						{
							bs.DataSource = args;
						}
						else
						{
							bs.DataSource = new List<Argument>();
						}
						arguments.DataSource = bs;
					}));
				}

				else if (msg.type == "stack" && msg.content != null)
				{
					//MessageBox.Show(msg.content);
					List<Argument> args = JsonConvert.DeserializeObject<List<Argument>>(msg.content);
					Invoke(new Action(() =>
					{
						BindingSource bs = new BindingSource();
						if (args != null)
						{
							bs.DataSource = args;
						}
						else
						{
							bs.DataSource = new List<Argument>();
						}

						procStack.DataSource = bs;
					}));
				}

				else if (msg.type == "callstack" && msg.content != null)
				{
					//MessageBox.Show(msg.content);
					List<string> procs = JsonConvert.DeserializeObject<List<string>>(msg.content);

					Invoke(new Action(() =>
					{
						BindingSource bs = new BindingSource();
						if (procs != null)
						{
							bs.DataSource = procs;
						}
						else
						{
							bs.DataSource = new List<Argument>();
						}
						callStack.DataSource = bs;
					}));
				}
			}
		}

		struct LocalVariable
		{
			public string ID { get; set; }
			public string Type { get; set; }
			public string Value { get; set; }
		}

		struct Argument
		{
			public string ID { get; set; }
			public string Type { get; set; }
			public string Value { get; set; }
		}

		class Shit
		{
			public string procname;
			public int offset;
		}

		private void toggleBreakpointButton_Click(object sender, EventArgs e)
		{
			if (!ready)
			{
				return;
			}
			if (disassembly.CurrentRow.DefaultCellStyle.BackColor == Color.Red)
			{
				disassembly.CurrentRow.DefaultCellStyle.BackColor = Color.White;
				ProcInfoRow pir = disassembly.CurrentRow.DataBoundItem as ProcInfoRow;
				if (pir != null)
				{
					disassembly.CurrentRow.DefaultCellStyle.SelectionBackColor = Color.LightGray;
					pir.BP = "";
				}
			}
			else
			{
				disassembly.CurrentRow.DefaultCellStyle.BackColor = Color.Red;
				ProcInfoRow pir = disassembly.CurrentRow.DataBoundItem as ProcInfoRow;
				if (pir != null)
				{
					disassembly.CurrentRow.DefaultCellStyle.SelectionBackColor = Color.Maroon;
					pir.BP = "X";
				}
				string name = procList.Items[procList.SelectedIndex].ToString();
				Dictionary<string, object> cont = new Dictionary<string, object>();
				cont["proc_name"] = name;
				cont["offset"] = pir.Offset;
				send_message("set_breakpoint", cont);
			}
		}

		private void disassembly_SelectionChanged(object sender, EventArgs e)
		{
			if (!ready)
			{
				return;
			}
			ProcInfoRow pir = disassembly.CurrentRow.DataBoundItem as ProcInfoRow;
			if (pir != null)
			{
				if (pir.isCurrent == ">")
				{
					disassembly.CurrentRow.DefaultCellStyle.SelectionBackColor = Color.DarkCyan;
				}
				else
				{
					if (pir.BP == "X")
					{
						disassembly.CurrentRow.DefaultCellStyle.SelectionBackColor = Color.Maroon;
					}
					else
					{
						disassembly.CurrentRow.DefaultCellStyle.SelectionBackColor = Color.LightGray;
					}
				}
			}
		}

		private void stepButton_Click(object sender, EventArgs e)
		{
			if (!ready)
			{
				return;
			}

			send_message("step");
		}

		ManualResetEvent oSignalEvent = new ManualResetEvent(false);
		private List<ProcInfoRow> fuck;

		private void procList_SelectedIndexChanged(object sender, EventArgs e)
		{
			if (!ready || procList.SelectedIndex == -1)
			{
				return;
			}
			string name = procList.Items[procList.SelectedIndex].ToString();
			if (procInfos[name].disassembly == null)
			{
				send_message("disassembly", name);
				oSignalEvent.WaitOne();
				oSignalEvent.Reset();
				procInfos[name].disassembly = fuck;
			}

			BindingSource bs = new BindingSource();
			bs.DataSource = procInfos[name].disassembly;
			disassembly.DataSource = bs;
		}

		private void searchButton_Click(object sender, EventArgs e)
		{
			if (!ready)
			{
				return;
			}
			procList.BeginUpdate();
			procList.Items.Clear();
			if (searchText.Text.Length == 0)
			{
				procList.Items.AddRange(procNames.ToArray());
				procList.EndUpdate();
				return;
			}
			procList.Items.AddRange(
				procNames.Where(i => i.Contains(searchText.Text)).ToArray());
			procList.EndUpdate();
		}

		private void runButton_Click(object sender, EventArgs e)
		{
			if (!ready)
			{
				return;
			}

			send_message("resume");
		}

		private void disassembly_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
		{
			foreach (DataGridViewRow row in disassembly.Rows)
			{
				if (row.Cells["isCurrent"].Value.ToString() == ">")
				{
					row.DefaultCellStyle.BackColor = Color.LightSkyBlue;
				}
				else
				{
					if (row.Cells["BP"].Value.ToString() == "X")
					{
						row.DefaultCellStyle.BackColor = Color.Red;
					}
					else
					{
						row.DefaultCellStyle.BackColor = Color.White;
					}
				}

			}
		}

        private void searchText_TextChanged(object sender, EventArgs e)
        {
            if (!ready)
            {
                return;
            }
            procList.BeginUpdate();
            procList.Items.Clear();
            if (searchText.Text.Length == 0)
            {
                procList.Items.AddRange(procNames.ToArray());
                procList.EndUpdate();
                return;
            }
            procList.Items.AddRange(
                procNames.Where(i => i.Contains(searchText.Text)).ToArray());
            procList.EndUpdate();
        }
    }
}
