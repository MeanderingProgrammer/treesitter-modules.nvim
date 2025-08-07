import re
from dataclasses import dataclass, field
from pathlib import Path
from textwrap import indent

import tree_sitter_lua
import tree_sitter_markdown
from tree_sitter import Language, Parser


@dataclass(frozen=True)
class LuaClass:
    value: str
    fields: list[str] = field(default_factory=list)

    def add(self, value: str) -> None:
        self.fields.append(value)

    def name(self) -> str:
        # ---@class ts.mod.Hl: ts.mod.Module -> ts.mod.Hl
        # ---@class (exact) ts.mod.Config    -> ts.mod.Config
        return self.value.split(":")[0].split()[-1]

    def to_user(self) -> str | None:
        kind = self.value.split()[1]
        simple = self.name().split(".")[-1]
        if kind != "(exact)" or simple != "Config":
            return None

        lines: list[str] = []
        values = [self.value] + self.fields
        for i, value in enumerate(values):
            value = value.replace(".Config", ".UserConfig")
            if i > 0:
                name = value.split()[1]
                assert not name.endswith("?")
                value = value.replace(f" {name} ", f" {name}? ")
            lines.append(value)
        return "\n".join(lines)


def main() -> None:
    root = next(Path("lua").glob("*"))
    update_types(root)
    update_readme(root)


def update_types(root: Path) -> None:
    files: list[Path] = [root.joinpath("init.lua")]
    files.extend(sorted(root.joinpath("core").iterdir()))
    files.extend(sorted(root.joinpath("mods").iterdir()))

    sections: list[str] = ["---@meta"]
    for lua_type in get_lua_types(files):
        user = lua_type.to_user()
        if user is not None:
            sections.append(user)

    types = root.joinpath("types.lua")
    types.write_text("\n\n".join(sections) + "\n")


def update_readme(root: Path) -> None:
    readme = Path("README.md")

    old = get_code_block(readme, 2)

    new = get_default(root.joinpath("init.lua"))
    new = f"require('{root.name}').setup({new})\n"
    while True:
        match = re.search(r"require\('(.*?)'\)\.default", new)
        if match is None:
            break
        statement = new[match.start() : match.end()]
        path = match.group(1).replace(".", "/")
        file = Path("lua").joinpath(path).with_suffix(".lua")
        config = indent(get_default(file), "    ").strip()
        new = new.replace(statement, config)

    text = readme.read_text().replace(old, new)
    readme.write_text(text)


def get_lua_types(files: list[Path]) -> list[LuaClass]:
    result: list[LuaClass] = []
    for file in files:
        for comment in get_comments(file):
            # ---@class (exact) ts.mod.Config          -> class
            # ---@field enable boolean                 -> field
            # ---@alias ts.mod.inc.Keymap string|false -> alias
            # ---| 'init_selection'                    -> ---|
            # ---@type ts.mod.Config                   -> type
            # ---@param opts? ts.mod.UserConfig        -> param
            annotation = comment.split()[0].split("@")[-1]
            if annotation == "class":
                result.append(LuaClass(comment))
            elif annotation == "field":
                result[-1].add(comment)
    return result


def get_comments(file: Path) -> list[str]:
    query = "(comment) @comment"
    return ts_query(file, query, "comment")


def get_default(file: Path) -> str:
    query = """
    (assignment_statement
        (variable_list
            name: (dot_index_expression
                field: (identifier) @name
                (#eq? @name "default")))
        (expression_list value: (table_constructor)) @value)
    """
    defaults = ts_query(file, query, "value")
    assert len(defaults) == 1
    return defaults[0]


def get_code_block(file: Path, n: int) -> str:
    query = "(code_fence_content) @content"
    code_blocks = ts_query(file, query, "content")
    assert len(code_blocks) > n
    return code_blocks[n]


def ts_query(file: Path, query: str, target: str) -> list[str]:
    tree_sitter = {
        ".lua": tree_sitter_lua,
        ".md": tree_sitter_markdown,
    }[file.suffix]

    language = Language(tree_sitter.language())
    tree = Parser(language).parse(file.read_text().encode())
    captures = language.query(query).captures(tree.root_node)

    nodes = captures.get(target, [])
    nodes.sort(key=lambda node: node.start_byte)
    texts = [node.text for node in nodes]
    return [text.decode() for text in texts if text is not None]


if __name__ == "__main__":
    main()
