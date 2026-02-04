
You are given an existing Swift source file named `Global.swift`.

The **FULL ORIGINAL CONTENT** of `Global.swift` is provided below.

Your task is to output a **modified version of the SAME FILE**.

---

## ABSOLUTE RULES (NON-NEGOTIABLE)

1. **You MUST reproduce the entire file**
2. **All code outside `action(onExit:)` MUST remain IDENTICAL, character-for-character**
3. You may modify **ONLY** the code between:

   ```
   // >>> EDITABLE START
   // >>> EDITABLE END
   ```
   
4. If any code outside the editable region is missing or altered, the output is **INVALID**
5. Output **ONLY** Swift source code

   * No markdown
   * No explanations

---

## Output Formatting Rules (CRITICAL)

You MUST output raw Swift source code only.

You MUST NOT:
- Wrap the output in ``` or ```swift
- Use any markdown code fences
- Add language identifiers
- Surround the code with backticks

If any backticks appear in the output, the result is INVALID.

---

## Editable Region (OUTPUT-ONLY)

The editable region is **OUTPUT ONLY**.

* Do NOT place instructions here
* Do NOT place pseudocode here
* Only Swift code is allowed

---

## Priority Rule (CRITICAL)

If **pseudocode is provided**, attempt to generate Swift code using the following priority order:

1. **Logic-Preserving Repair Conversion** (preferred)
2. **Legacy Stub Generation** (fallback)

You must choose **exactly one**.

---

## Mode 1 — Pseudocode → Runnable Swift (Logic-Preserving Repair)

Use this mode **ONLY IF** the pseudocode:

* Describes executable logic
* Clearly indicates algorithmic intent
* Can be made runnable **without changing logic direction**

### Repair Contract

The pseudocode represents the **intended algorithmic idea**.

You may **repair structural issues** required for compilation and execution, but you must **NOT change the logic direction**.

---

### ✅ Allowed Repairs (MINIMAL ONLY)

You MAY:

1. Fix inconsistent identifiers

   * `h1` vs `head1`
2. Make implicit steps explicit

   * pointer advancement (`node = node.next`)
   * loop termination implied by the pseudocode
3. Translate informal notes into concrete syntax

   * “if null, set to 0”
   * “get integral only”
4. Resolve ambiguous constructors or calls

   * `node { value }` → `ListNode(value)`
5. Add required variable declarations or types for compilation

---

### ❌ Forbidden Changes

You must NOT:

1. Change the algorithmic strategy
2. Optimize or refactor
3. Remove or reorder logical steps
4. Add new data structures not implied
5. Improve correctness beyond the pseudocode’s intent
6. Add tests, logging, or scaffolding

---

### Logic Preservation Rule

* Operation order must remain intact
* Control-flow decisions must reflect original intent
* Any repair must be the **smallest possible change** that enables execution

If multiple repairs are possible:

* Choose the **most literal** one

---

### Output Rules (Repair Mode)

* Emit **only runnable Swift code**
* Place **all generated code** strictly inside:

  ```
  // >>> EDITABLE START
  // >>> EDITABLE END
  ```
  
* Do NOT generate `Solution` wrappers
* Sample input creation, execution, and output printing

MUST follow the same structure as Legacy Stub Generation.

* IMPORTANT:

Even in Repair Mode, you MUST output the FULL `Global.swift` file.
Only the contents between `// >>> EDITABLE START` and `// >>> EDITABLE END`
may differ from the original input.

---

## Mode 2 — Legacy Stub Generation (Fallback)

Use this mode **ONLY IF**:

* Pseudocode is missing
* OR pseudocode is contradictory
* OR generating runnable code would require guessing or changing logic direction

### Stub Behavior (UNCHANGED)

Inside `// >>> EDITABLE START` and `// >>> EDITABLE END`:

1. Define required data structures
2. Create default sample input data
3. Declare a `Solution` type with the correct method signature
4. Provide a **STUB implementation only**

   * Use `// TODO`
   * Return a valid placeholder value
5. Execute the solution with sample input
6. Print the output

This mode must preserve **existing test behavior**.

---

## Type Declaration Rules (Legacy Mode Only)

* No type declarations inside `action`
* All types must be declared at file scope
* Default access control only
* Helper types must appear above `class Global`

---

## Pseudocode Input (OPTIONAL — SOURCE OF INTENT)

If present, the following pseudocode expresses the **algorithmic idea**:

```
{{PSEUDO_CODE}}
```

* Do NOT copy it verbatim
* Do NOT improve the algorithm
* Use it only to guide logic-preserving repair

---

## Input Delimiter Semantics (CRITICAL)

Triple backticks (```) used in this prompt are for
INPUT DELIMITING ONLY.

They are NOT part of `Global.swift`.

You MUST NOT reproduce any ``` characters
that appear in this prompt.

---

## ORIGINAL FILE (INPUT — MUST BE REPRODUCED)

Paste the full current contents of `Global.swift` below:

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

## Output Validation Checklist (IMPLICIT)

Before producing output, ensure:

* [ ] Entire file is reproduced
* [ ] Only editable region changed
* [ ] Logic direction preserved (if converting)
* [ ] Stub behavior preserved (if fallback)
* [ ] No text outside Swift source code

---

### Mental Model (MANDATORY)

> “I am not improving this algorithm.
> I am only fixing what is necessary so it can run.”
