variable "string_heredoc_type" {
  description = "This is a variable of type string"
  type        = string
  default     = <<EOF
hello, this is Sumeet.
Do visit my website!
EOF
}