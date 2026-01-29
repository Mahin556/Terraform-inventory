```hcl
TERRAFORM STRING FORMATTING EXAMPLES (format() FUNCTION)

format("<pattern>", values...)

────────────────────────────────────

%s  → STRING

format("Hello %s", "Mahin")
→ "Hello Mahin"

format("User: %s, Role: %s", "Mahin", "DevOps")
→ "User: Mahin, Role: DevOps"

────────────────────────────────────

%d  → INTEGER

format("You have %d servers", 5)
→ "You have 5 servers"

format("Port number: %d", 8080)
→ "Port number: 8080"

────────────────────────────────────

%f  → FLOAT

format("CPU usage: %f", 72.5)
→ "CPU usage: 72.500000"

format("Price: $%.2f", 19.987)
→ "Price: $19.99"

────────────────────────────────────

%t  → BOOLEAN

format("Monitoring enabled: %t", true)
→ "Monitoring enabled: true"

format("Is production? %t", false)
→ "Is production? false"

────────────────────────────────────

%v  → DEFAULT FORMAT (ANY TYPE)

format("Value: %v", "text")
→ "Value: text"

format("Value: %v", 123)
→ "Value: 123"

format("Value: %v", true)
→ "Value: true"

format("Value: %v", ["a", "b"])
→ "Value: [a b]"

format("Value: %v", {env="dev"})
→ "Value: map[env:dev]"

────────────────────────────────────

WIDTH & PRECISION

format("%5d", 7)
→ "    7"   (5 width)

format("%-5d", 7)
→ "7    "   (left aligned)

format("%.2f", 3.14159)
→ "3.14"

format("%8.2f", 3.5)
→ "    3.50"

────────────────────────────────────

MULTIPLE VALUES

format("%s has %d pods running (healthy: %t)", "cluster-1", 12, true)
→ "cluster-1 has 12 pods running (healthy: true)"

────────────────────────────────────

REAL TERRAFORM EXAMPLE

output "server_info" {
  value = format("Server %s | CPU: %.1f%% | Active: %t", "web-01", 72.6, true)
}
```