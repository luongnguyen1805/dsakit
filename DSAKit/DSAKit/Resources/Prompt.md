
You are given an existing Swift source file named `Global.swift`.

The **FULL ORIGINAL CONTENT** of `Global.swift` is provided below.

Your task is to output a **modified version of the SAME FILE**.

---

## ABSOLUTE RULES (NON-NEGOTIABLE)

1. **You MUST reproduce the entire file**
2. **All code outside `action(onExit:)` MUST remain IDENTICAL, character-for-character**
3. You may modify **ONLY the body of `action1(onExit:)`**
4. If any code outside `action` is missing or altered, the output is INVALID

---

## Editable Region (ONLY)

You may modify **ONLY** the section marked:

```swift
// >>> EDITABLE START
// >>> EDITABLE END
```

Everything else is READ-ONLY.

---

## ORIGINAL FILE (INPUT — MUST BE REPRODUCED)

Paste the full current `Global.swift` here, for example:

```
class Global
{
    static let shared = Global()

    private init() { }

    func action(onExit: @escaping ()->Void)
    {
        print("\n----------")

        print("\n\rProblem Source: {{PROBLEM_SOURCE}}")
        print("\rProblem Title: {{PROBLEM_TITLE}}")
        print("\r")

        // >>> EDITABLE START
        //Setup and Todo
        // >>> EDITABLE END

        print("\n----------")
        onExit()
    }
}
```

---

## What to generate INSIDE the editable region

Inside `// >>> EDITABLE START` and `// >>> EDITABLE END`:

1. Define required data structures
2. Create default sample input data
3. Declare a `Solution` type with the correct method signature
4. Provide a STUB implementation only
   * Use `// TODO`
   * Return a valid placeholder value
5. Execute the solution with sample input
6. Print the output

---

## Type Declaration Rules (MANDATORY)

* **NO type declarations are allowed inside `action`**
* All structs, classes, enums, protocols, and typealiases MUST be declared at **file scope**
* Do NOT use `public`, `open`, or `internal`
* Use default access control only
* Helper types MUST be declared **above `class Global`**
* `action` may only contain:
  * variable declarations
  * sample data
  * `Solution` instantiation
  * method calls
  * `print`
  * `onExit()`

---
## Constraints

* DO NOT solve the problem
* DO NOT include real algorithm logic
* DO NOT use stdin, files, or network
* DO NOT modify formatting, spacing, or prints
* Code must compile and run locally

---

## Output Rules (STRICT)

* Output **ONLY the full Swift source code**
* NO markdown
* NO explanations
* The output must be a drop-in replacement for `Global.swift`
* **DO NOT** wrap code in `swift` or any markdown
* The output must be **exactly what will be written to `Global.swift`**
* The file must **compile and run immediately** on macOS using Swift

---

## Problem Metadata

Problem Source:
{{PROBLEM_SOURCE}}

Problem Title:
{{PROBLEM_TITLE}}

Problem Description:
{{PROBLEM_DESCRIPTION}}

