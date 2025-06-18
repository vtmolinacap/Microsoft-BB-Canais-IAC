variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
}

variable "virtual_machine" {
  type = any
}
