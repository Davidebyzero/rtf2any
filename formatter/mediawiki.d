module rtf2any.formatter.mediawiki;

import rtf2any.common;
import rtf2any.formatter.nested;
import std.string;
import std.array;

class MediaWikiFormatter : NestedFormatter
{
	this(Block[] blocks)
	{
		// Force terminating of all formatting on the same line
		foreach (ref block; blocks)
			if (block.type == BlockType.NewParagraph)
			{
				block.attr.fontSize = 0;
				block.attr.bold = block.attr.italic = block.attr.underline = false;
				block.attr.fontColor = int.max;
			}
		super(blocks);
	}

	int listLevel, bulletPending;
	bool inTable;

	void pre()
	{
		if (bulletPending && listLevel)
		{
			if (!inTable)
			{
				foreach (i; 0..listLevel)
					s ~= "*";
				s ~= " ";
			}
			bulletPending = false;
		}
	}

	@property bool paraStart()
	{
		auto index = blockIndex;
		// Skip dummy nodes as per NestedFormatter.preprocess
		while (index && blocks[index-1].type == BlockType.Text && blocks[index-1].text == "")
			index--;
		return index==0 || blocks[index-1].type == BlockType.NewParagraph;
	}
	@property bool paraEnd() { return blockIndex==blocks.length || blocks[blockIndex].type == BlockType.NewParagraph; }

	override void addText(string text) { pre(); if (inTable) text = text.replace("\t", " || "); s ~= text.replace("<", "&lt;").replace(">", "&gt;").replace("{{", "<nowiki>{{</nowiki>").replace("}}", "<nowiki>}}</nowiki>"); }
	override void newParagraph() { if (!inTable) s ~= "\n"; else s ~= "\n|-\n| "; if (listLevel) bulletPending = true; }

	override void addBold(bool enabled) { pre(); s ~= "'''"; }
	override void addItalic(bool enabled) { pre(); s ~= "''"; }
	override void addUnderline(bool enabled) { pre(); s ~= enabled ? "<u>" : "</u>"; }
	override void addIndent(int left, int firstLine, bool list) { listLevel += list; bulletPending = true; }
	override void addFontSize(int size) { pre(); if (size > 25 && paraStart) s ~= "== "; else if (size > 20 && paraStart) s ~= "=== "; else if (size < 20) s ~= "<small>"; }
	override void addFontColor(int color) { pre(); s ~= .format(`<span style="color: #%06x">`, color); }
	override void addTabs(int[] tabs) { if (listLevel==0) { inTable = true; s ~= "{|\n| "; } }
	
	override void removeBold(bool enabled) { pre(); s ~= "'''"; }
	override void removeItalic(bool enabled) { pre(); s ~= "''"; }
	override void removeUnderline(bool enabled) { pre(); s ~= enabled ? "</u>" : "<u>"; }
	override void removeIndent(int left, int firstLine, bool list) { listLevel -= list; }
	override void removeFontSize(int size) { if (size > 25 && paraEnd) s ~= " =="; else if (size > 20 && paraEnd) s ~= " ==="; else if (size < 20) s ~= "</small>"; }
	override void removeFontColor(int color) { s ~= "</span>"; }
	override void removeTabs(int[] tabs) { if (inTable) { inTable = false; s = s[0..$-5] ~ "|}\n"; } }
}

