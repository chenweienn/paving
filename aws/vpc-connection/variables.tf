variable "environment_name_1" {
  type = string
}
variable "environment_name_2" {
  type = string
}

variable "region_1" {
  type = string
}
variable "region_2" {
  type = string
}

variable "vpc_id_1" {
  type = string
}
variable "vpc_id_2" {
  type = string
}

variable "tgw_id_1" {
  type = string
}
variable "tgw_id_2" {
  type = string
}

variable "vpc_attachment_subnet_ids_1" {
  type = list
}
variable "vpc_attachment_subnet_ids_2" {
  type = list
}



#variable "transit_gateway_peering" {
#  default     = false
#  description = "Control creation of transit gateway peering connection attachment."
#  type        = bool
#}


variable "tags_1" {
  description = "Key/value tags to assign to all resources."
  default     = {}
  type        = map(string)
}
variable "tags_2" {
  description = "Key/value tags to assign to all resources."
  default     = {}
  type        = map(string)
}

