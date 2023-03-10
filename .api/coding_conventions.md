[ᐊ Return to repo](https://github.com/Timmy-the-nobody/WebUI3d2d)

# 💡 Pull Requests
If you want to do a PR, please follow some conventions in your code in order to facilitate reading, refactoring, and communication within the team

## 🐙 Commit conventions
* Follow [SemVer](https://semver.org/) convention for version naming
* Describe the features, fixes, breaking changes, and so on.. made in commit messages
* The commit message should be structured as follows:
```md
<type> [optional scope/feature]: <description>
```
* Commit types:
  - `feat`: addition of a new feature
  - `fix`: fix a bug
  - `perf`: performance improvement
  - `refactor`: change that doesn't bring any new feature or performance improvement
  - `style`: change that doesn't bring any functional or semantic alteration (indentation, adding a space, renaming a variable...)
  - `docs`: writing or updating documentation
  - `test`: adding or modifying tests
  - `chore`: no production code change (editing .gitignore, gitattributes...)
  - `!`: breaking changes, it must be indicated by a `!` immediately before the `:`
* Example:
```md
docs (coding conventions): add commit conventions
```

## 📙 Basics

* Keep your code consistant and follow all the points listed below
* Avoid redundant code, e.g: prefer a function to a duplication of the same conditions
* Avoid passing packets through the network unnecessarily (e.g. using the broadcast parameter of `SetValue` when only one client needs it's data)
* Localize your functions/variables/tables/etc.. whenever it's possible, always use the smallest scope possible
* Localize heavy globals on the top of your files when they're called often
* Avoid heavy operations in `Tick` events
* Triple check what's sent by clients throught the network!
* Avoid looping through big tables
* Add validity checks in delayed operations (timers, SQL fetch, etc..)

## 🖋️ Syntax : Variables

* Global vars must be formatted in **PascalCase**
* Local vars must be formatted in **camelCase**
* Enum vars must be formatted in **UPPERCASE**
* It's a general rule (not necessarily a Lua one) that variable names with larger scope should be more descriptive than those with smaller scope
* Variables holding values or objects are typically lowercase and short
* Constants/Enums, particularly ones that are simple values, are often given in `ALL_CAPS`, with words optionally separated by underscores 
* Class names (or at least metatables representing classes) may be mixed case (BankAccount)
* Names starting with an underscore followed by uppercase letters (such as `_VERSION`) are reserved for internal global variables

Indicate the variable type with the first letter of the variable (except for functions and enums):

* **b**Bool
* **i**Int
* **f**Float
* **s**String
* **t**Table
* **x**Undefined
* **o**Object
* **p**Player (instance of nanos world `Player` class)
* **e**Entity (instance of a nanos world `BaseActor` derived class)

## 😎 Syntax : Style
* Indent with 4 spaces
* Use a space after a `--` comment
* Always put a space after commas and assignment signs
* Add brackets to your comparison operations, or your mathematical operations
* Avoid aligning variable declarations
* Indent tables and functions according to the start of the line, not the construct
* False and nil are falsy in conditional expressions. Use shortcuts when you can, unless you need to know the difference between false and nil
* Even though Lua allows it, do not omit parenthesis for functions that take a unique string literal argument
* Prefer function syntax over variable syntax. This helps differentiate between named and anonymous functions
* Perform validation as early as possible in your functions/loops/..., and return/break/goto as early as possible to avoid pyramids of conditions
