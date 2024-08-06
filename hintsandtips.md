## Hints and tips

- if you deploy the template but never authorise the API Connection, the Fabric Capacity will never pause.  Either pause the capacity manually or authorise the connection.

### Convert an ARM template to bicep

1. Export the ARM template from the Azure portal
2. Run the following code to decompile it:

```
az bicep decompile --file main.json
```

See here for more info: https://stackoverflow.com/questions/69354469/is-there-a-way-to-generate-a-bicep-file-for-an-existing-azure-resource



## Steps for migrating workspaces from one sub to another
1. Create new external Azure subscription
2. Add all old workspaces to github repos
3. Create new Fabric capacity in new subscription