namespace debugger
{
	partial class DMDBG
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.stepButton = new System.Windows.Forms.Button();
            this.resumeButton = new System.Windows.Forms.Button();
            this.toggleBreakpointButton = new System.Windows.Forms.Button();
            this.disassembly = new System.Windows.Forms.DataGridView();
            this.BP = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.isCurrent = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Offset = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Bytes = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Mnemonic = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Comment = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.procList = new System.Windows.Forms.ListBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.searchText = new System.Windows.Forms.TextBox();
            this.searchButton = new System.Windows.Forms.Button();
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.splitContainer3 = new System.Windows.Forms.SplitContainer();
            this.localVariables = new System.Windows.Forms.DataGridView();
            this.ID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Type = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Value = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.splitContainer4 = new System.Windows.Forms.SplitContainer();
            this.arguments = new System.Windows.Forms.DataGridView();
            this.dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn3 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.procStack = new System.Windows.Forms.DataGridView();
            this.dataGridViewTextBoxColumn4 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn5 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dataGridViewTextBoxColumn6 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.status = new System.Windows.Forms.ToolStripStatusLabel();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabDisassembly = new System.Windows.Forms.TabPage();
            this.tabCallStack = new System.Windows.Forms.TabPage();
            this.callStack = new System.Windows.Forms.ListBox();
            this.flowLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.disassembly)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.tableLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.Panel2.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer3)).BeginInit();
            this.splitContainer3.Panel1.SuspendLayout();
            this.splitContainer3.Panel2.SuspendLayout();
            this.splitContainer3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.localVariables)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer4)).BeginInit();
            this.splitContainer4.Panel1.SuspendLayout();
            this.splitContainer4.Panel2.SuspendLayout();
            this.splitContainer4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.arguments)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.procStack)).BeginInit();
            this.tableLayoutPanel2.SuspendLayout();
            this.statusStrip.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabDisassembly.SuspendLayout();
            this.tabCallStack.SuspendLayout();
            this.SuspendLayout();
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Controls.Add(this.stepButton);
            this.flowLayoutPanel1.Controls.Add(this.resumeButton);
            this.flowLayoutPanel1.Controls.Add(this.toggleBreakpointButton);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(3, 3);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(780, 29);
            this.flowLayoutPanel1.TabIndex = 0;
            // 
            // stepButton
            // 
            this.stepButton.Location = new System.Drawing.Point(3, 3);
            this.stepButton.Name = "stepButton";
            this.stepButton.Size = new System.Drawing.Size(75, 23);
            this.stepButton.TabIndex = 0;
            this.stepButton.Text = "Step";
            this.stepButton.UseVisualStyleBackColor = true;
            this.stepButton.Click += new System.EventHandler(this.stepButton_Click);
            // 
            // resumeButton
            // 
            this.resumeButton.Location = new System.Drawing.Point(84, 3);
            this.resumeButton.Name = "resumeButton";
            this.resumeButton.Size = new System.Drawing.Size(75, 23);
            this.resumeButton.TabIndex = 1;
            this.resumeButton.Text = "Resume";
            this.resumeButton.UseVisualStyleBackColor = true;
            this.resumeButton.Click += new System.EventHandler(this.runButton_Click);
            // 
            // toggleBreakpointButton
            // 
            this.toggleBreakpointButton.Location = new System.Drawing.Point(165, 3);
            this.toggleBreakpointButton.Name = "toggleBreakpointButton";
            this.toggleBreakpointButton.Size = new System.Drawing.Size(131, 23);
            this.toggleBreakpointButton.TabIndex = 2;
            this.toggleBreakpointButton.Text = "Toggle Breakpoint";
            this.toggleBreakpointButton.UseVisualStyleBackColor = true;
            this.toggleBreakpointButton.Click += new System.EventHandler(this.toggleBreakpointButton_Click);
            // 
            // disassembly
            // 
            this.disassembly.AllowUserToAddRows = false;
            this.disassembly.AllowUserToDeleteRows = false;
            this.disassembly.AllowUserToResizeRows = false;
            this.disassembly.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.disassembly.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
            this.disassembly.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.disassembly.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.BP,
            this.isCurrent,
            this.Offset,
            this.Bytes,
            this.Mnemonic,
            this.Comment});
            this.disassembly.Dock = System.Windows.Forms.DockStyle.Fill;
            this.disassembly.Location = new System.Drawing.Point(0, 0);
            this.disassembly.Name = "disassembly";
            this.disassembly.ReadOnly = true;
            this.disassembly.RowHeadersVisible = false;
            this.disassembly.RowTemplate.ReadOnly = true;
            this.disassembly.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.disassembly.ShowEditingIcon = false;
            this.disassembly.Size = new System.Drawing.Size(611, 262);
            this.disassembly.TabIndex = 0;
            this.disassembly.DataBindingComplete += new System.Windows.Forms.DataGridViewBindingCompleteEventHandler(this.disassembly_DataBindingComplete);
            this.disassembly.SelectionChanged += new System.EventHandler(this.disassembly_SelectionChanged);
            // 
            // BP
            // 
            this.BP.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.BP.DataPropertyName = "BP";
            this.BP.FillWeight = 51.97886F;
            this.BP.Frozen = true;
            this.BP.HeaderText = "BP";
            this.BP.Name = "BP";
            this.BP.ReadOnly = true;
            this.BP.Width = 15;
            // 
            // isCurrent
            // 
            this.isCurrent.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.isCurrent.DataPropertyName = "isCurrent";
            this.isCurrent.HeaderText = "";
            this.isCurrent.Name = "isCurrent";
            this.isCurrent.ReadOnly = true;
            this.isCurrent.Width = 15;
            // 
            // Offset
            // 
            this.Offset.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.Offset.DataPropertyName = "Offset";
            dataGridViewCellStyle1.Format = "X04";
            this.Offset.DefaultCellStyle = dataGridViewCellStyle1;
            this.Offset.FillWeight = 39.12079F;
            this.Offset.HeaderText = "Offset";
            this.Offset.Name = "Offset";
            this.Offset.ReadOnly = true;
            this.Offset.Width = 49;
            // 
            // Bytes
            // 
            this.Bytes.DataPropertyName = "Bytes";
            this.Bytes.FillWeight = 115.0321F;
            this.Bytes.HeaderText = "Bytes";
            this.Bytes.Name = "Bytes";
            this.Bytes.ReadOnly = true;
            // 
            // Mnemonic
            // 
            this.Mnemonic.DataPropertyName = "Mnemonic";
            this.Mnemonic.FillWeight = 146.9341F;
            this.Mnemonic.HeaderText = "Mnemonic";
            this.Mnemonic.Name = "Mnemonic";
            this.Mnemonic.ReadOnly = true;
            // 
            // Comment
            // 
            this.Comment.DataPropertyName = "Comment";
            this.Comment.FillWeight = 146.9341F;
            this.Comment.HeaderText = "Comment";
            this.Comment.Name = "Comment";
            this.Comment.ReadOnly = true;
            // 
            // procList
            // 
            this.tableLayoutPanel1.SetColumnSpan(this.procList, 2);
            this.procList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.procList.FormattingEnabled = true;
            this.procList.Location = new System.Drawing.Point(3, 28);
            this.procList.Name = "procList";
            this.procList.Size = new System.Drawing.Size(159, 355);
            this.procList.TabIndex = 0;
            this.procList.SelectedIndexChanged += new System.EventHandler(this.procList_SelectedIndexChanged);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(3, 38);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.tableLayoutPanel1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.splitContainer2);
            this.splitContainer1.Size = new System.Drawing.Size(780, 354);
            this.splitContainer1.SplitterDistance = 165;
            this.splitContainer1.TabIndex = 3;
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel1.ColumnCount = 2;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 87.64706F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 12.35294F));
            this.tableLayoutPanel1.Controls.Add(this.procList, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.searchText, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.searchButton, 1, 0);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.GrowStyle = System.Windows.Forms.TableLayoutPanelGrowStyle.FixedSize;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 2;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 25F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.Size = new System.Drawing.Size(165, 354);
            this.tableLayoutPanel1.TabIndex = 3;
            // 
            // searchText
            // 
            this.searchText.Dock = System.Windows.Forms.DockStyle.Fill;
            this.searchText.Location = new System.Drawing.Point(3, 3);
            this.searchText.Name = "searchText";
            this.searchText.Size = new System.Drawing.Size(138, 20);
            this.searchText.TabIndex = 1;
            this.searchText.TextChanged += new System.EventHandler(this.searchText_TextChanged);
            // 
            // searchButton
            // 
            this.searchButton.Dock = System.Windows.Forms.DockStyle.Fill;
            this.searchButton.Location = new System.Drawing.Point(145, 1);
            this.searchButton.Margin = new System.Windows.Forms.Padding(1);
            this.searchButton.Name = "searchButton";
            this.searchButton.Size = new System.Drawing.Size(19, 23);
            this.searchButton.TabIndex = 2;
            this.searchButton.Text = "S";
            this.searchButton.UseVisualStyleBackColor = true;
            this.searchButton.Click += new System.EventHandler(this.searchButton_Click);
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(0, 0);
            this.splitContainer2.Name = "splitContainer2";
            this.splitContainer2.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.Controls.Add(this.disassembly);
            // 
            // splitContainer2.Panel2
            // 
            this.splitContainer2.Panel2.Controls.Add(this.splitContainer3);
            this.splitContainer2.Size = new System.Drawing.Size(611, 354);
            this.splitContainer2.SplitterDistance = 262;
            this.splitContainer2.TabIndex = 3;
            // 
            // splitContainer3
            // 
            this.splitContainer3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer3.Location = new System.Drawing.Point(0, 0);
            this.splitContainer3.Name = "splitContainer3";
            // 
            // splitContainer3.Panel1
            // 
            this.splitContainer3.Panel1.Controls.Add(this.localVariables);
            // 
            // splitContainer3.Panel2
            // 
            this.splitContainer3.Panel2.Controls.Add(this.splitContainer4);
            this.splitContainer3.Size = new System.Drawing.Size(611, 88);
            this.splitContainer3.SplitterDistance = 203;
            this.splitContainer3.TabIndex = 0;
            // 
            // localVariables
            // 
            this.localVariables.AllowUserToAddRows = false;
            this.localVariables.AllowUserToDeleteRows = false;
            this.localVariables.AllowUserToResizeRows = false;
            this.localVariables.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.localVariables.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.localVariables.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ID,
            this.Type,
            this.Value});
            this.localVariables.Dock = System.Windows.Forms.DockStyle.Fill;
            this.localVariables.Location = new System.Drawing.Point(0, 0);
            this.localVariables.Name = "localVariables";
            this.localVariables.RowHeadersVisible = false;
            this.localVariables.Size = new System.Drawing.Size(203, 88);
            this.localVariables.TabIndex = 0;
            // 
            // ID
            // 
            this.ID.DataPropertyName = "ID";
            this.ID.FillWeight = 10F;
            this.ID.Frozen = true;
            this.ID.HeaderText = "ID";
            this.ID.MinimumWidth = 25;
            this.ID.Name = "ID";
            this.ID.ReadOnly = true;
            this.ID.Width = 43;
            // 
            // Type
            // 
            this.Type.DataPropertyName = "Type";
            this.Type.FillWeight = 45F;
            this.Type.HeaderText = "Type";
            this.Type.MinimumWidth = 50;
            this.Type.Name = "Type";
            this.Type.Width = 56;
            // 
            // Value
            // 
            this.Value.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Value.DataPropertyName = "Value";
            this.Value.FillWeight = 45F;
            this.Value.HeaderText = "Value";
            this.Value.MinimumWidth = 100;
            this.Value.Name = "Value";
            // 
            // splitContainer4
            // 
            this.splitContainer4.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer4.Location = new System.Drawing.Point(0, 0);
            this.splitContainer4.Name = "splitContainer4";
            // 
            // splitContainer4.Panel1
            // 
            this.splitContainer4.Panel1.Controls.Add(this.arguments);
            // 
            // splitContainer4.Panel2
            // 
            this.splitContainer4.Panel2.Controls.Add(this.procStack);
            this.splitContainer4.Size = new System.Drawing.Size(404, 88);
            this.splitContainer4.SplitterDistance = 198;
            this.splitContainer4.TabIndex = 0;
            // 
            // arguments
            // 
            this.arguments.AllowUserToAddRows = false;
            this.arguments.AllowUserToDeleteRows = false;
            this.arguments.AllowUserToResizeRows = false;
            this.arguments.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.arguments.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.arguments.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.dataGridViewTextBoxColumn1,
            this.dataGridViewTextBoxColumn2,
            this.dataGridViewTextBoxColumn3});
            this.arguments.Dock = System.Windows.Forms.DockStyle.Fill;
            this.arguments.Location = new System.Drawing.Point(0, 0);
            this.arguments.Name = "arguments";
            this.arguments.RowHeadersVisible = false;
            this.arguments.Size = new System.Drawing.Size(198, 88);
            this.arguments.TabIndex = 1;
            // 
            // dataGridViewTextBoxColumn1
            // 
            this.dataGridViewTextBoxColumn1.DataPropertyName = "ID";
            this.dataGridViewTextBoxColumn1.FillWeight = 10F;
            this.dataGridViewTextBoxColumn1.Frozen = true;
            this.dataGridViewTextBoxColumn1.HeaderText = "ID";
            this.dataGridViewTextBoxColumn1.MinimumWidth = 25;
            this.dataGridViewTextBoxColumn1.Name = "dataGridViewTextBoxColumn1";
            this.dataGridViewTextBoxColumn1.ReadOnly = true;
            this.dataGridViewTextBoxColumn1.Width = 43;
            // 
            // dataGridViewTextBoxColumn2
            // 
            this.dataGridViewTextBoxColumn2.DataPropertyName = "Type";
            this.dataGridViewTextBoxColumn2.FillWeight = 45F;
            this.dataGridViewTextBoxColumn2.HeaderText = "Type";
            this.dataGridViewTextBoxColumn2.MinimumWidth = 50;
            this.dataGridViewTextBoxColumn2.Name = "dataGridViewTextBoxColumn2";
            this.dataGridViewTextBoxColumn2.Width = 56;
            // 
            // dataGridViewTextBoxColumn3
            // 
            this.dataGridViewTextBoxColumn3.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.dataGridViewTextBoxColumn3.DataPropertyName = "Value";
            this.dataGridViewTextBoxColumn3.FillWeight = 45F;
            this.dataGridViewTextBoxColumn3.HeaderText = "Value";
            this.dataGridViewTextBoxColumn3.MinimumWidth = 100;
            this.dataGridViewTextBoxColumn3.Name = "dataGridViewTextBoxColumn3";
            // 
            // procStack
            // 
            this.procStack.AllowUserToAddRows = false;
            this.procStack.AllowUserToDeleteRows = false;
            this.procStack.AllowUserToResizeRows = false;
            this.procStack.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.procStack.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.procStack.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.dataGridViewTextBoxColumn4,
            this.dataGridViewTextBoxColumn5,
            this.dataGridViewTextBoxColumn6});
            this.procStack.Dock = System.Windows.Forms.DockStyle.Fill;
            this.procStack.Location = new System.Drawing.Point(0, 0);
            this.procStack.Name = "procStack";
            this.procStack.RowHeadersVisible = false;
            this.procStack.Size = new System.Drawing.Size(202, 88);
            this.procStack.TabIndex = 2;
            // 
            // dataGridViewTextBoxColumn4
            // 
            this.dataGridViewTextBoxColumn4.DataPropertyName = "ID";
            this.dataGridViewTextBoxColumn4.FillWeight = 10F;
            this.dataGridViewTextBoxColumn4.Frozen = true;
            this.dataGridViewTextBoxColumn4.HeaderText = "ID";
            this.dataGridViewTextBoxColumn4.MinimumWidth = 25;
            this.dataGridViewTextBoxColumn4.Name = "dataGridViewTextBoxColumn4";
            this.dataGridViewTextBoxColumn4.ReadOnly = true;
            this.dataGridViewTextBoxColumn4.Width = 43;
            // 
            // dataGridViewTextBoxColumn5
            // 
            this.dataGridViewTextBoxColumn5.DataPropertyName = "Type";
            this.dataGridViewTextBoxColumn5.FillWeight = 45F;
            this.dataGridViewTextBoxColumn5.HeaderText = "Type";
            this.dataGridViewTextBoxColumn5.MinimumWidth = 50;
            this.dataGridViewTextBoxColumn5.Name = "dataGridViewTextBoxColumn5";
            this.dataGridViewTextBoxColumn5.Width = 56;
            // 
            // dataGridViewTextBoxColumn6
            // 
            this.dataGridViewTextBoxColumn6.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.dataGridViewTextBoxColumn6.DataPropertyName = "Value";
            this.dataGridViewTextBoxColumn6.FillWeight = 45F;
            this.dataGridViewTextBoxColumn6.HeaderText = "Value";
            this.dataGridViewTextBoxColumn6.MinimumWidth = 100;
            this.dataGridViewTextBoxColumn6.Name = "dataGridViewTextBoxColumn6";
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel2.ColumnCount = 1;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.Controls.Add(this.flowLayoutPanel1, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.splitContainer1, 0, 1);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(3, 3);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 3;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 35F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 23F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(786, 418);
            this.tableLayoutPanel2.TabIndex = 3;
            // 
            // statusStrip
            // 
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.status});
            this.statusStrip.Location = new System.Drawing.Point(0, 428);
            this.statusStrip.Name = "statusStrip";
            this.statusStrip.Size = new System.Drawing.Size(800, 22);
            this.statusStrip.TabIndex = 4;
            this.statusStrip.Text = "statusStrip1";
            // 
            // status
            // 
            this.status.Name = "status";
            this.status.Size = new System.Drawing.Size(21, 17);
            this.status.Text = "...?";
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabDisassembly);
            this.tabControl1.Controls.Add(this.tabCallStack);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(800, 450);
            this.tabControl1.TabIndex = 3;
            // 
            // tabDisassembly
            // 
            this.tabDisassembly.Controls.Add(this.tableLayoutPanel2);
            this.tabDisassembly.Location = new System.Drawing.Point(4, 22);
            this.tabDisassembly.Name = "tabDisassembly";
            this.tabDisassembly.Padding = new System.Windows.Forms.Padding(3);
            this.tabDisassembly.Size = new System.Drawing.Size(792, 424);
            this.tabDisassembly.TabIndex = 0;
            this.tabDisassembly.Text = "Disassembly";
            this.tabDisassembly.UseVisualStyleBackColor = true;
            // 
            // tabCallStack
            // 
            this.tabCallStack.Controls.Add(this.callStack);
            this.tabCallStack.Location = new System.Drawing.Point(4, 22);
            this.tabCallStack.Name = "tabCallStack";
            this.tabCallStack.Padding = new System.Windows.Forms.Padding(3);
            this.tabCallStack.Size = new System.Drawing.Size(792, 424);
            this.tabCallStack.TabIndex = 1;
            this.tabCallStack.Text = "Call Stack";
            this.tabCallStack.UseVisualStyleBackColor = true;
            // 
            // callStack
            // 
            this.callStack.Dock = System.Windows.Forms.DockStyle.Fill;
            this.callStack.FormattingEnabled = true;
            this.callStack.Location = new System.Drawing.Point(3, 3);
            this.callStack.Name = "callStack";
            this.callStack.Size = new System.Drawing.Size(786, 418);
            this.callStack.TabIndex = 0;
            // 
            // DMDBG
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.statusStrip);
            this.Controls.Add(this.tabControl1);
            this.Name = "DMDBG";
            this.Text = "DMDBG";
            this.Load += new System.EventHandler(this.DMDBG_Load);
            this.flowLayoutPanel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.disassembly)).EndInit();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.splitContainer2.Panel1.ResumeLayout(false);
            this.splitContainer2.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            this.splitContainer3.Panel1.ResumeLayout(false);
            this.splitContainer3.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer3)).EndInit();
            this.splitContainer3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.localVariables)).EndInit();
            this.splitContainer4.Panel1.ResumeLayout(false);
            this.splitContainer4.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer4)).EndInit();
            this.splitContainer4.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.arguments)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.procStack)).EndInit();
            this.tableLayoutPanel2.ResumeLayout(false);
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tabDisassembly.ResumeLayout(false);
            this.tabCallStack.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
		private System.Windows.Forms.Button stepButton;
		private System.Windows.Forms.Button resumeButton;
		private System.Windows.Forms.Button toggleBreakpointButton;
		private System.Windows.Forms.DataGridView disassembly;
		private System.Windows.Forms.ListBox procList;
		private System.Windows.Forms.SplitContainer splitContainer1;
		private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
		private System.Windows.Forms.TextBox searchText;
		private System.Windows.Forms.Button searchButton;
		private System.Windows.Forms.SplitContainer splitContainer2;
		private System.Windows.Forms.SplitContainer splitContainer3;
		private System.Windows.Forms.DataGridView localVariables;
		private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
		private System.Windows.Forms.StatusStrip statusStrip;
		private System.Windows.Forms.DataGridViewTextBoxColumn ID;
		private System.Windows.Forms.DataGridViewTextBoxColumn Type;
		private System.Windows.Forms.DataGridViewTextBoxColumn Value;
		private System.Windows.Forms.SplitContainer splitContainer4;
		private System.Windows.Forms.DataGridView arguments;
		private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn1;
		private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn2;
		private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn3;
		private System.Windows.Forms.DataGridView procStack;
		private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn4;
		private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn5;
		private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn6;
		private System.Windows.Forms.TabControl tabControl1;
		private System.Windows.Forms.TabPage tabDisassembly;
		private System.Windows.Forms.TabPage tabCallStack;
		private System.Windows.Forms.ListBox callStack;
		private System.Windows.Forms.ToolStripStatusLabel status;
        private System.Windows.Forms.DataGridViewTextBoxColumn BP;
        private System.Windows.Forms.DataGridViewTextBoxColumn isCurrent;
        private System.Windows.Forms.DataGridViewTextBoxColumn Offset;
        private System.Windows.Forms.DataGridViewTextBoxColumn Bytes;
        private System.Windows.Forms.DataGridViewTextBoxColumn Mnemonic;
        private System.Windows.Forms.DataGridViewTextBoxColumn Comment;
    }
}

