locals {
  // Only add local variables if it would be much cleaner vs re-entering the value

  // datetime is going to be added to tags for terraform creation date, lives here because it needs to...
  datetime     = { date_processed = formatdate("YYYYMMDDhhmmss", timestamp()) }
}