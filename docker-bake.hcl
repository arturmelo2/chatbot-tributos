group "default" {
  targets = ["api"]
}

target "api" {
  context    = "."
  dockerfile = "dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = [
    "arturmdmm/whatsapp-ai-chatbot:latest",
  ]
  output     = ["type=registry"]
  pull       = true
  cache-from = [
    "type=registry,ref=arturmdmm/whatsapp-ai-chatbot:buildcache",
  ]
  cache-to = [
    "type=registry,ref=arturmdmm/whatsapp-ai-chatbot:buildcache,mode=max",
  ]
}
