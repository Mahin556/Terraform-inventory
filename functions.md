# ⭐ **MASTER LIST OF ALL TERRAFORM FUNCTIONS**

Terraform has **14 categories** of functions:

1. String Functions
2. Numeric Functions
3. Collection Functions
4. Encoding Functions
5. Filesystem Functions
6. Date & Time Functions
7. Crypto & Hash Functions
8. IP Network Functions
9. Type Conversion Functions
10. Structural Manipulation (Objects & Maps)
11. Dynamic & Experimental Functions
12. Terraform State/Runtime Functions
13. Language Meta Functions
14. Other Utility Functions

I will give:

✔ Function name
✔ Short explanation
✔ Simple example
✔ Result

---

# ⭐ 1. **STRING FUNCTIONS**

| Function       | Example                            | Result                |
| -------------- | ---------------------------------- | --------------------- |
| `upper()`      | `upper("hello")`                   | `"HELLO"`             |
| `lower()`      | `lower("Hello")`                   | `"hello"`             |
| `title()`      | `title("my app")`                  | `"My App"`            |
| `chomp()`      | `chomp("hello\n")`                 | `"hello"`             |
| `trim()`       | `trim(" abc ")`                    | `"abc"`               |
| `trimspace()`  | `trimspace("  hi  ")`              | `"hi"`                |
| `substr()`     | `substr("abcdef", 1, 3)`           | `"bcd"`               |
| `replace()`    | `replace("a-b-c", "-", "_")`       | `"a_b_c"`             |
| `regex()`      | `regex("[0-9]+", "abc123")`        | `"123"`               |
| `regexall()`   | `regexall("[0-9]", "a1b2c3")`      | `["1","2","3"]`       |
| `format()`     | `format("Hello %s", "John")`       | `"Hello John"`        |
| `formatlist()` | `formatlist("item %s", ["a","b"])` | `["item a","item b"]` |
| `split()`      | `split(",", "a,b,c")`              | `["a","b","c"]`       |
| `join()`       | `join("-", ["a","b"])`             | `"a-b"`               |
| `startswith()` | `startswith("abc", "a")`           | `true`                |
| `endswith()`   | `endswith("abc", "c")`             | `true`                |
| `contains()`   | `contains(["a","b"], "b")`         | `true`                |
| `strrev()`     | `strrev("abc")`                    | `"cba"`               |
| `indent()`     | `indent("hello", 4)`               | `"    hello"`         |
| `trim()`       | `trim("!!abc!!", "!")`             | `"abc"`               |

---

# ⭐ 2. **NUMERIC FUNCTIONS**

| Function   | Example        | Result |
| ---------- | -------------- | ------ |
| `min()`    | `min(3, 5, 1)` | `1`    |
| `max()`    | `max(3, 5, 1)` | `5`    |
| `ceil()`   | `ceil(4.2)`    | `5`    |
| `floor()`  | `floor(4.8)`   | `4`    |
| `abs()`    | `abs(-10)`     | `10`   |
| `pow()`    | `pow(2, 3)`    | `8`    |
| `signum()` | `signum(-5)`   | `-1`   |

---

# ⭐ 3. **COLLECTION FUNCTIONS (LIST, MAP, SET)**

| Function     | Example                      | Result      |
| ------------ | ---------------------------- | ----------- |
| `length()`   | `length([1,2,3])`            | `3`         |
| `element()`  | `element(["a","b","c"], 1)`  | `"b"`       |
| `slice()`    | `slice(["a","b","c"], 0, 2)` | `["a","b"]` |
| `concat()`   | `concat([1],[2])`            | `[1,2]`     |
| `flatten()`  | `flatten([[1,2],[3]])`       | `[1,2,3]`   |
| `distinct()` | `distinct([1,1,2])`          | `[1,2]`     |
| `sort()`     | `sort(["c","a"])`            | `["a","c"]` |
| `reverse()`  | `reverse(["a","b"])`         | `["b","a"]` |
| `keys()`     | `keys({a=1,b=2})`            | `["a","b"]` |
| `values()`   | `values({a=1,b=2})`          | `[1,2]`     |
| `merge()`    | `merge({a=1},{b=2})`         | `{a=1,b=2}` |
| `lookup()`   | `lookup({a=1},"a")`          | `1`         |
| `contains()` | `contains(["a","b"], "b")`   | `true`      |
| `zipmap()`   | `zipmap(["a","b"], [1,2])`   | `{a=1,b=2}` |

---

# ⭐ 4. **ENCODING FUNCTIONS**

| Function         | Example                    | Result       |
| ---------------- | -------------------------- | ------------ |
| `jsonencode()`   | `jsonencode({a=1})`        | `'{"a":1}'`  |
| `jsondecode()`   | `jsondecode("{\"a\":1}")`  | `{a=1}`      |
| `yamlencode()`   | `yamlencode({a=1})`        | `"a: 1"`     |
| `yamldecode()`   | `yamldecode("a: 1")`       | `{a=1}`      |
| `base64encode()` | `base64encode("hello")`    | `"aGVsbG8="` |
| `base64decode()` | `base64decode("aGVsbG8=")` | `"hello"`    |

---

# ⭐ 5. **FILESYSTEM FUNCTIONS**

| Function       | Example                          | Result              |
| -------------- | -------------------------------- | ------------------- |
| `file()`       | `file("data.txt")`               | contents of file    |
| `filebase64()` | `filebase64("bin.zip")`          | base64 encoded data |
| `filemd5()`    | `filemd5("file.txt")`            | `"md5hash"`         |
| `filesha1()`   | `filesha1("file.txt")`           | SHA1                |
| `fileset()`    | `fileset("./configs", "*.json")` | list of files       |

---

# ⭐ 6. **DATE & TIME FUNCTIONS**

| Function      | Example                      | Result                   |
| ------------- | ---------------------------- | ------------------------ |
| `timestamp()` | `timestamp()`                | `"2025-01-30T06:02:15Z"` |
| `timeadd()`   | `timeadd(timestamp(), "1h")` | timestamp + 1 hour       |
| `uuid()`      | `uuid()`                     | random UUID              |

---

# ⭐ 7. **CRYPTO & HASH FUNCTIONS**

| Function   | Example                | Result                               |
| ---------- | ---------------------- | ------------------------------------ |
| `md5()`    | `md5("hello")`         | `"5d41402abc4b2a76b9719d911017c592"` |
| `sha1()`   | `sha1("hello")`        | SHA1 hash                            |
| `sha256()` | `sha256("hello")`      | SHA256 hash                          |
| `bcrypt()` | `bcrypt("mypassword")` | bcrypt hash                          |

---

# ⭐ 8. **IP NETWORK FUNCTIONS**

| Function        | Example                           | Result            |
| --------------- | --------------------------------- | ----------------- |
| `cidrhost()`    | `cidrhost("10.0.0.0/16", 5)`      | `"10.0.0.5"`      |
| `cidrsubnet()`  | `cidrsubnet("10.0.0.0/16", 4, 2)` | `"10.0.32.0/20"`  |
| `cidrnetmask()` | `cidrnetmask("10.0.0.0/24")`      | `"255.255.255.0"` |
| `cidr2mask()`   | `cidr2mask(24)`                   | `"255.255.255.0"` |

---

# ⭐ 9. **TYPE CONVERSION FUNCTIONS**

| Function     | Example                | Result      |
| ------------ | ---------------------- | ----------- |
| `tostring()` | `tostring(123)`        | `"123"`     |
| `tonumber()` | `tonumber("123")`      | `123`       |
| `tolist()`   | `tolist({a=1,b=2})`    | list        |
| `tomap()`    | `tomap([1,2])`         | map         |
| `toset()`    | `toset(["a","b","b"])` | `["a","b"]` |
| `tomap()`    | `tomap({a=1})`         | map         |

---

# ⭐ 10. **STRUCTURAL FUNCTIONS (MAP/OBJECT/LIST PROCESSING)**

| Function            | Example                   | Result      |
| ------------------- | ------------------------- | ----------- |
| `coalesce()`        | `coalesce("", "abc")`     | `"abc"`     |
| `coalescelist()`    | `coalescelist([], ["a"])` | `["a"]`     |
| `compact()`         | `compact(["a", "", "b"])` | `["a","b"]` |
| `zipmap()`          | `zipmap(["a"], [1])`      | `{a=1}`     |
| `setintersection()` | intersection              | set         |
| `setunion()`        | union                     | set         |

---

# ⭐ 11. **DYNAMIC / EXPERIMENTAL FUNCTIONS**

| Function         | Example                      |
| ---------------- | ---------------------------- |
| `dynamic` blocks | create dynamic nested blocks |

---

# ⭐ 12. **STATE/RUNTIME FUNCTIONS**

| Function         | Example                 | Result      |
| ---------------- | ----------------------- | ----------- |
| `path.module`    | `${path.module}`        | module path |
| `path.root`      | root path               |             |
| `try()`          | `try(var.a, "default")` | fallback    |
| `can()`          | `can(var.a.b)`          | true/false  |
| `nonsensitive()` | remove sensitive flag   |             |
| `sensitive()`    | mark sensitive          |             |

---

# ⭐ 13. **LANGUAGE META FUNCTIONS**

| Function              | Example             | Result           |
| --------------------- | ------------------- | ---------------- |
| `terraform.workspace` | `"default"`         | active workspace |
| `var.*`               | variable access     |                  |
| `local.*`             | locals              |                  |
| `depends_on`          | resource dependency |                  |

---

# ⭐ 14. **UTILITY FUNCTIONS**

| Function   | Example             | Result |
| ---------- | ------------------- | ------ |
| `uuidv5()` | UUID v5             |        |
| `merge()`  | merge multiple maps |        |

