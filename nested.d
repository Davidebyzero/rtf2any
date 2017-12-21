module rtf2any.nested;

import std.conv;
import std.string;
import rtf2any.common;

class NestedFormatter
{
	string s;

	enum FormatChange : ulong
	{
		Bold,
		Italic,
		Underline,
		Center,
		SubScript,
		SuperScript,
		Paragraph0,
		// ...
		ParagraphMax = Paragraph0 + 100000,
		Column0,
		// ...
		ColumnMax = Column0 + 1000,
		ListLevel0,
		// ...
		ListLevelMax = ListLevel0 + 10,
		Font0,
		// ...
		FontMax = Font0 + 100,
		FontSize0,
		// ...
		FontSizeMax = FontSize0 + 1000,
		FontColor0,
		// ...
		FontColorMax = FontColor0 + 0x1000000,
		Tabs0,
		// ...
		TabsMax = Tabs0 + 0x1_0000_0000,
	}

	Block[] blocks;
	size_t blockIndex;

	this(Block[] blocks)
	{
		this.blocks = blocks;
	}

	static FormatChange[] attrToChanges(BlockAttr attr)
	{
		FormatChange[] list;
		if (attr.font)
			list ~= cast(FormatChange)(FormatChange.Font0 + attr.font.index);
		if (attr.fontSize)
			list ~= cast(FormatChange)(FormatChange.FontSize0 + attr.fontSize);
		for (int i=1; i<=attr.listLevel; i++)
			list ~= cast(FormatChange)(FormatChange.ListLevel0 + i);
		if (attr.tabs.length)
			list ~= cast(FormatChange)(FormatChange.Tabs0 + (hashOf(attr.tabs, 0) & 0xFFFF_FFFF));
		if (attr.center)
			list ~= FormatChange.Center;
		if (attr.fontColor)
			list ~= cast(FormatChange)(FormatChange.FontColor0 + attr.fontColor);
		if (attr.paragraphIndex >= 0)
			list ~= cast(FormatChange)(FormatChange.Paragraph0 + attr.paragraphIndex);
		if (attr.columnIndex >= 0)
			list ~= cast(FormatChange)(FormatChange.Column0 + attr.columnIndex);
		if (attr.bold)
			list ~= FormatChange.Bold;
		if (attr.italic)
			list ~= FormatChange.Italic;
		if (attr.underline)
			list ~= FormatChange.Underline;
		if (attr.subSuper == SubSuper.subscript)
			list ~= FormatChange.SubScript;
		if (attr.subSuper == SubSuper.superscript)
			list ~= FormatChange.SuperScript;
		return list;
	}

	static bool haveFormat(FormatChange[] stack, FormatChange format)
	{
		foreach (f; stack)
			if (f == format)
				return true;
		return false;
	}

	static bool haveFormat(FormatChange[] stack, FormatChange min, FormatChange max)
	{
		foreach (f; stack)
			if (f >= min && f<=max)
				return true;
		return false;
	}
	
	abstract void addText(string s);
	void newParagraph() {}
	void newPage() {}

	void addBold() {}
	void addItalic() {}
	void addUnderline() {}
	void addCenter() {}
	void addSubSuper(SubSuper subSuper) {}
	void addListLevel(int level) {}
	void addFont(Font* font) {}
	void addFontSize(int size) {}
	void addFontColor(int color) {}
	void addTabs(int[] tabs) {}
	void addInParagraph(int index) {}
	void addInColumn(int index) {}
	
	void removeBold() {}
	void removeItalic() {}
	void removeUnderline() {}
	void removeCenter() {}
	void removeSubSuper(SubSuper subSuper) {}
	void removeListLevel(int level) {}
	void removeFont(Font* font) {}
	void removeFontSize(int size) {}
	void removeFontColor(int color) {}
	void removeTabs(int[] tabs) {}
	void removeInParagraph(int index) {}
	void removeInColumn(int index) {}

	void flush() {}

	final void addFormat(FormatChange f, ref Block block)
	{
		if (f == FormatChange.Bold)
			addBold();
		else
		if (f == FormatChange.Italic)
			addItalic();
		else
		if (f == FormatChange.Underline)
			addUnderline();
		else
		if (f == FormatChange.Center)
			addCenter();
		else
		if (f == FormatChange.SubScript)
			addSubSuper(SubSuper.subscript);
		else
		if (f == FormatChange.SuperScript)
			addSubSuper(SubSuper.superscript);
		else
		if (f >= FormatChange.ListLevel0 && f <= FormatChange.ListLevelMax)
			addListLevel(to!int(f - FormatChange.ListLevel0));
		else
		if (f >= FormatChange.Font0 && f <= FormatChange.FontMax)
			addFont(block.attr.font);
		else
		if (f >= FormatChange.FontSize0 && f <= FormatChange.FontSizeMax)
			addFontSize(to!int(f - FormatChange.FontSize0));
		else
		if (f >= FormatChange.FontColor0 && f <= FormatChange.FontColorMax)
			addFontColor(to!int(f - FormatChange.FontColor0));
		else
		if (f >= FormatChange.Tabs0 && f <= FormatChange.TabsMax)
			addTabs(block.attr.tabs);
		else
		if (f >= FormatChange.Paragraph0 && f <= FormatChange.ParagraphMax)
			addInParagraph(to!int(f - FormatChange.Paragraph0));
		else
		if (f >= FormatChange.Column0 && f <= FormatChange.ColumnMax)
			addInColumn(to!int(f - FormatChange.Column0));
		else
			assert(0);
	}
	
	final void removeFormat(FormatChange f, ref Block block)
	{
		if (f == FormatChange.Bold)
			removeBold();
		else
		if (f == FormatChange.Italic)
			removeItalic();
		else
		if (f == FormatChange.Underline)
			removeUnderline();
		else
		if (f == FormatChange.Center)
			removeCenter();
		else
		if (f == FormatChange.SubScript)
			removeSubSuper(SubSuper.subscript);
		else
		if (f == FormatChange.SuperScript)
			removeSubSuper(SubSuper.superscript);
		else
		if (f >= FormatChange.ListLevel0 && f <= FormatChange.ListLevelMax)
			removeListLevel(to!int(f - FormatChange.ListLevel0));
		else
		if (f >= FormatChange.Font0 && f <= FormatChange.FontMax)
			removeFont(block.attr.font);
		else
		if (f >= FormatChange.FontSize0 && f <= FormatChange.FontSizeMax)
			removeFontSize(to!int(f - FormatChange.FontSize0));
		else
		if (f >= FormatChange.FontColor0 && f <= FormatChange.FontColorMax)
			removeFontColor(to!int(f - FormatChange.FontColor0));
		else
		if (f >= FormatChange.Tabs0 && f <= FormatChange.TabsMax)
			removeTabs(block.attr.tabs);
		else
		if (f >= FormatChange.Paragraph0 && f <= FormatChange.ParagraphMax)
			removeInParagraph(to!int(f - FormatChange.Paragraph0));
		else
		if (f >= FormatChange.Column0 && f <= FormatChange.ColumnMax)
			removeInColumn(to!int(f - FormatChange.Column0));
		else
			assert(0);
	}

	final bool canSplitFormat(FormatChange f)
	{
		if (f >= FormatChange.Paragraph0 && f <= FormatChange.ParagraphMax)
			return false;
		else
		if (f >= FormatChange.Column0 && f <= FormatChange.ColumnMax)
			return false;
		else
			return true;
	}

	string format()
	{
		FormatChange[] stack;
		s = null;

		// Duplicate the properties of a paragraph's delimiter to its
		// beginning as a fake text node, so that the list->tree
		// algorithm below promotes properties (e.g. font size) which
		// correspond to the paragraph delimiter.
		{
			BlockAttr* paragraphAttr;
			foreach_reverse (bi, ref block; blocks)
				if (block.type == BlockType.NewParagraph)
				{
					if (paragraphAttr)
					{
						Block start;
						start.type = BlockType.Text;
						start.text = null;
						start.attr = *paragraphAttr;
						blocks = blocks[0..bi+1] ~ start ~ blocks[bi+1..$];
					}
					paragraphAttr = &block.attr;
				}
		}

		foreach (bi, ref block; blocks)
		{
			blockIndex = bi;

			FormatChange[] newList = attrToChanges(block.attr);

			// Gracious unwind (popping things off the top of the stack)
			while (stack.length && !haveFormat(newList, stack[$-1]))
			{
				removeFormat(stack[$-1], blocks[bi-1]);
				stack = stack[0..$-1];
			}

			// Brutal unwind (popping things out from the middle of the stack)
			foreach (i, f; stack)
				if (!haveFormat(newList, f))
				{
					bool canSplit = true;
					foreach (rf; stack[i+1..$])
						if (!canSplitFormat(rf))
						{
							canSplit = false;
							break;
						}

					if (canSplit)
					{
						// Unwind stack to remove all formats no
						// longer present, and everything that came on
						// top of them in the stack.
						foreach_reverse (rf; stack[i..$])
							removeFormat(rf, blocks[bi-1]);
						stack = stack[0..i];
						break;
					}
					else
					{
						// Just let the new format to be added to the
						// top of the stack, overriding the old one.
					}
				}

			// Add new and re-add unwound formatters.
			foreach (f; newList)
				if (!haveFormat(stack, f))
				{
					stack ~= f;
					addFormat(f, block);
				}

			switch (block.type)
			{
				case BlockType.Text:
					addText(block.text);
					break;
				case BlockType.NewParagraph:
					newParagraph();
					break;
				case BlockType.Tab:
					break;
				case BlockType.PageBreak:
					newPage();
					break;
				default:
					assert(0);
			}
		}

		// close remaining tags
		blockIndex = blocks.length;
		foreach_reverse(rf; stack)
			removeFormat(rf, blocks[$-1]);

		flush();

		return s;
	}

	static string dumpBlocks(Block[] blocks)
	{
		string s;
		foreach (block; blocks)
		{
			string[] attrs;
			foreach (f; attrToChanges(block.attr))
				if (f == FormatChange.Bold)
					attrs ~= "Bold";
				else
				if (f == FormatChange.Italic)
					attrs ~= "Italic";
				else
				if (f == FormatChange.Underline)
					attrs ~= "Underline";
				else
				if (f == FormatChange.Center)
					attrs ~= "Center";
				else
				if (f == FormatChange.SubScript)
					attrs ~= "SubScript";
				else
				if (f == FormatChange.SuperScript)
					attrs ~= "SuperScript";
				else
				if (f >= FormatChange.ListLevel0 && f <= FormatChange.ListLevelMax)
					attrs ~= .format("List level %d", cast(int)(f - FormatChange.ListLevel0));
				else
				if (f >= FormatChange.Font0 && f <= FormatChange.FontMax)
					attrs ~= .format("Font %s", block.attr.font);
				else
				if (f >= FormatChange.FontSize0 && f <= FormatChange.FontSizeMax)
					attrs ~= .format("Font size %d", cast(int)(f - FormatChange.FontSize0));
				else
				if (f >= FormatChange.FontColor0 && f <= FormatChange.FontColorMax)
					attrs ~= .format("Font color #%06x", cast(int)(f - FormatChange.FontColor0));
				else
				if (f >= FormatChange.Tabs0 && f <= FormatChange.TabsMax)
					attrs ~= .format("Tab count %d", cast(int)(f - FormatChange.Tabs0));
				else
				if (f >= FormatChange.Paragraph0 && f <= FormatChange.ParagraphMax)
					attrs ~= .format("Paragraph %d", cast(int)(f - FormatChange.Paragraph0));
				else
					assert(0);
			string text;
			switch (block.type)
			{
			case BlockType.Text:
				text = block.text;
				break;
			case BlockType.NewParagraph:
				text = "NewParagraph";
				break;
			case BlockType.PageBreak:
				text = "PageBreak";
				break;
			default:
				assert(0);
			}
			s ~= .format("%s:\n%s\n", attrs, text);
		}
		return s;
	}
}
