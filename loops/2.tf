# Add a Prefix to List Elements
locals {
  prefix_elements = [for elem in ["a", "b", "c"] : format("Hello %s", elem)]
}
# Result: ["Hello a", "Hello b", "Hello c"]


#Filter List Using if in for Loop (Even Numbers)
locals {
  even_numbers = [for i in [1, 2, 3, 4, 5, 6] : i if i % 2 == 0]
}
# Result: [2, 4, 6]
