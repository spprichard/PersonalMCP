#  API

Currently I am thinking this project will be similar to API.me...
1 difference is that this project will have an MCP API & a REST API. 

## Project 
### Current State:
- Created Version 1 of the email server
    - Currently just returns stubbed out data 
- Stoodup MCP Server

### Next Steps
- Replace stubs with real calls to IMAP server using SwiftMail (Email API Server)
- Verify generated email client works
    - Assuming this works, add MCP tool call which uses generated client to perform get mail/search

## REST API
### Email
#### Current State: 
- Created a basic OpenAPI Spec
- Allows for type, client & server


#### Next:
- Use latest version of SwiftMail to get emails with attachments
    - Create an Endpoint for this to allow for getting emails from a specific mailbox
    - Create an Endpoint for getting the content of an attachment    
---
## MCP API
### Current State:  
[*] Have a basic greet & ping tool call

### Next:
- Explore how we could use Templated Resources 
    - Could leverage Email API? 



