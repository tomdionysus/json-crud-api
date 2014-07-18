# json-crud-api Roadmap

The following features should be implemented by version ```0.2.0```.


## Query Syntax Extensions

### Filtering

Specifying ```<field>[.<operation>]=<value>``` in the query will filter the result set by the appropriate field, operation and value, e.g.

  GET /addresses?postcode=6011
	GET /addresses?postcode.eq=6011
	GET /addresses?street.eq=Grafton%20Street&postcode.eq=6011
	GET /addresses?number.lte=15&postcode.eq=6011
	
	PUT /addresses?postcode=6011
	{
		"postcode": "6002"
	}
	
	DELETE
	
	GET /addresses?_embed=tenants&person.age.gte=18
	
Valid operations are as follows:

| Operation       | Description             |
|:----------------|:------------------------|
| eq (default)    | Equals		              |
| ne              | Does Not Equal          |
| lt              | Less Than	              |
| gt              | Greater Than            |
| lte             | Less Than or Equal      |
| gte             | Greater Than or Equals  |
| like            | Is Like                 |
| notlike         | Is Not Like             |


### Include/Exclude Fields

Two modes are available from an API response:

#### Include only specific fields
Adding ```_include=<field_1>,<field_2>,<relation.field_1>...``` in the query will include **only** the specified fields.

	GET /addresses?_include=number,street,postcode,country
	
	[
		{ "number":"20", "street":"Cable Street", "postcode":"6011", "New Zealand" },
		{ "number":"90", "street":"Troy Street", "postcode":"6011", "New Zealand" }
	]

#### Exclude specific fields
Specifying ```_exclude=<field_1>,<field_2>,<relation.field_1>...``` in the query will include **all fields except** the specified fields.

	GET /addresses?_exclude=country
	
	[
		{ "id":"2374623", "number":"20", "street":"Cable Street", "city":"Wellington", "postcode":"6011" },
		{ "id":"5812382", "number":"90", "street":"Troy Street", "city":"Wellington", "postcode":"6011" }
	]

### Related Entities

Relations may be included in one of two ways:

#### Linked Relations
Specifying ```_link=<relation_1>,<relation_2>...``` in the query will include the **id**, or list of **id**s of the related entity in the response
	
	GET /addresses?_link=tenants,landlord
	
	[
		{ 
			"id":"2374623", "number":"20", "street":"Cable Street", "city":"Wellington", "postcode":"6011", 
			"tenants":[5423,2312], "landlord":7241
		},
		{
			"id":"5812382", "number":"90", "street":"Troy Street", "city":"Wellington", "postcode":"6011", 
			"tenants":[6562,1933,8172], "landlord":8182
		}
	]

#### Embedded Relations
Specifying ```_embed=<relation_1>,<relation_2>...``` in the query will embed the full **object** or list of **objects** in the response.

	GET /addresses?_embed=tenants,landlord
	
	[
		{ 
			"id":"2374623", "number":"20", "street":"Cable Street", "city":"Wellington", "postcode":"6011", 
			"tenants": [
				{ "id":5423, "name": "Keith Green" },
				{ "id":2312, "name": "Susan Brown" }
			], 
			"landlord": {
				"id": 7241, "name": "Joe Smith"
			}
		},
		{
			"id":"5812382", "number": "90", "street": "Troy Street", "city": "Wellington", "postcode": "6011", 
			"tenants": [
				{ "id":6562, "name": "Tom Black" },
				{ "id":1933, "name": "Matt White" },
				{ "id":8172, "name": "Joe Brown" }
			], 
			"landlord": {
				"id": 8182, "name": "John Smith"
			}
		}
	]
	
	GET /addresses/5812382?_embed=tenants&tenants.name.like=Whitehall
	
	{
    	{
    	"id":"5812382", "number": "90", "street": "Troy Street", "city": "Wellington", "postcode":"6011", 
    	"tenants": [
      		{ "id":1933, "name": "Matt White" }
    	], 
    	"landlord": {
      		"id": 8182, "name": "John Smith"
    	}
  	}
	
### Multiple Entity IDs

You can specify multiple IDs on resources by separating the ids with commas:

	GET /addresses/2,3,8,10
	
