# API Documentation

## Base URL

The URL format for the generated API is:

	https://server/database/action?OpenAgent&param1=value1&..

Component | Notes
----------|------
server | A FQDN or IP address.  This can also include a port
database | The path to the Domino database, relative to the Notes Data Directory
action | Follows the format AllowedTVs<Action>.  See [Actions](#actions) below
`?OpenAgent` | This is required by Domino to reference the agent.
Parameters | See [Shared Parameters](#shared-parameters) and [Actions](#actions)

## HTTP Operations

All actions may be submitted as `GET` or `POST`.  `POST` is recommended for Create and Update actions.

## Security

By default, the agents are generated with a default SecurityInterface that allows all actions.  This can be updated by updating this method in each agent:

```
	protected SecurityInterface getSecurity()
```

I indicated where the `SecurityInterface` will be checked for each action with the corresponding `getSecurity()` calls.


## Data Types

The following data types are supported:

Type | Multivalue | JSON Format | Parameter Format | Notes
-----|------------|-------------|------------------|------
TEXT | false | String | String | 
TEXT | true | Array of Strings | JSON Array or a semicolon separated String | 
NUMBER | false | double | double | All number types will be treated as floats by the API.  If you pass `null`, `''`, or `'null'` in a parameter, the value will be cleared.
NUMBER | true | Array of doubles | JSON Array of doubles or a semicolon separated String. | 
DATETIME | false | String in [ISO 8601 format](https://en.wikipedia.org/wiki/ISO_8601) | Currently all dates are returned as full date-time values with the format `2022-03-16T00:00:00-05:00`, but in the future date-only or time-only values may be supported.  If you pass `null`, `''`, or `'null'` in a parameter, the value will be cleared.
DATETIME | true | Array of Strings in [ISO 8601 format](https://en.wikipedia.org/wiki/ISO_8601) | JSON Array or a semicolon separated String of date-time values (see above). | 
RICHTEXT | false | String in HTML format | The rich text is encoded as HTML to preserve formatting.  Multivalue RICHTEXT values are not supported.

For multivalue fields, the JSON array format is recommended, since the semicolon separated string will cause trouble if any of the values contain semicolons.

## Shared Parameters

The following parameters are available on all actions

Parameter | Optional (Default) | Notes
----------|--------------------|------
`f` | Yes (`json`) | Output format.  The options are `json` (default) and `xml`


## Shared Response

These properties will be available in all responses.

Property | Description
---------|------------
errorMessage | If this is `null` or '', the action was successful.  Otherwise, this is an error message that can be reported to the user.
state | Determines whether the action is authenticated properly.  "authenticated" means the user had sufficient access for the action (Uses `getSecurity().allowAction()`).  "anonymous" indicates the user was anonymous and action required authentication.  "authenticated-with-insufficient-access" means the user didn't have sufficient access.
username | The name of the authenticated user, or "Anonymous" if the user is not authenticated



## Actions

The parameter names will match the field names.  The action documents will reference different types of fields for the parameters.  
The parameter and returned fields can be modified for individual agents

Any provided parameters will be validated for their type (see "Data Types").  If the type is invalid, the agent will report an `errorMessage`.  
TODO:  support special format?

### Document Objects

`Document` objects are returned by some agents.

Document properties | Type | Multivalue | Notes
--------------------|------|------------|------
DominoUniveralID    | Text | No         | Used as the lookup key for Create and Update agents.
ID | Text | false | AppleTV item ID
tvName | Text | false | 
availableCameras | Text | true | Camera IDs available to the particular TV


### Create

Create a new document.  Run `Document.computeWithForm` before saving the document.  Validation:
- key fields are defined
- No existing document matches the keys
- Check `getSecurity().allowAccess(Document)` on the new document before saving.

Parameters | Type | Multivalue | Required | Notes
-----------|------|------------|----------|------
ID | Text | false | false | AppleTV item ID
tvName | Text | false | false | 
availableCameras | Text | true | false | Camera IDs available to the particular TV


Response properties | JSON Format | Notes
--------------------|-------------|------
`document` | [Document Object](#document-objects) | The new document, including computed fields and DocumentUniversalID.


### Read

Read all documents.  If keys are provided, return only the document matching the key.  Validation:
- If any keys are provided, all keys must be provided and have valid types.
- Check `getSecurity().allowAccess(Document)` for each document

Parameters | Type | Multivalue | Required | Notes
-----------|------|------------|----------|------
tvName | Text | false | true | 


Response properties | JSON Format | Notes
--------------------|-------------|------
`documents` | Array of [Document Objects](#document-objects) | If a key was provided, only a single document will be returned (The agent can be updated to change this logic).



### Update

Update a document.  Run `Document.computeWithForm` before saving the document.  Validation:
- key fields are defined
- A document matches the provided keys
- Check `getSecurity().allowAccess(Document)` on the original document
- Check `getSecurity().allowAccess(Document)` on the updated document before saving.

Parameters | Type | Multivalue | Required | Notes
-----------|------|------------|----------|------
DominoUniversalID | Text | No | Yes | 
ID | Text | false | false | AppleTV item ID
tvName | Text | false | false | 
availableCameras | Text | true | false | Camera IDs available to the particular TV


Response:  No additional values.  TODO: return the document?


### Delete

Delete a document.  Validation:
- key fields are defined
- A document matches the provided keys
- Check `getSecurity().allowAccess(Document)` on the original document

Parameters | Type | Multivalue | Required | Notes
-----------|------|------------|----------|------
DominoUniversalID | Text | No | Yes | 

Response:  No additional values.

