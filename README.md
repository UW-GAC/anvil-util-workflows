# anvil-util-workflows

Utilities for checking files in AnVIL

## data_model_report

This workflow checks whether expected tables (both required and optional) are included. For each table, it checks column names, data types, and primary keys. Finally, it checks foreign keys (cross-references across tables). Results of all checks are displayed in an HTML file.

If the data model specifies that any columns be auto-generated from other columns, the workflow returns TSV files with updated tables. The user can then use functions from the AnvilDataModels](https://github.com/UW-GAC/AnvilDataModels) package to import these tables to an AnVIL workspace.

The user must specify the following inputs:

input | description
--- | ---
table_files | This input is of type Map[String, File], which consists of key:value pairs. Keys are table names, which should correspond to names in the data model, and values are Google bucket paths to TSV files for each table.
model_url | A URL providing the path to the data model in JSON format.
out_prefix | A prefix for the resulting HTML report.

The workflow returns the following outputs:

output | description
--- | ---
file_report | An HTML file with check results
tables | A file array with the tables after adding auto-generated columns. These tables can be imported into an AnVIL workspace as data tables. This output is not generated if no additional columns are specified in the data model.
pass_checks | a boolean value where 'true' means the set of tables fulfilled the minimum requirements of the data model (all required tables/columns present)


## data_table_import

This workflow imports TSV files into AnVIL data tables. It does the same checks as data_model_report before import, and fails if minimum checks are not passed.

The user must specify the following inputs:

input | description
--- | ---
table_files | This input is of type Map[String, File], which consists of key:value pairs. Keys are table names, which should correspond to names in the data model, and values are Google bucket paths to TSV files for each table.
model_url | A URL providing the path to the data model in JSON format.
workspace_name | A string with the workpsace name. e.g, if the workspace URL is https://anvil.terra.bio/#workspaces/fc-product-demo/Terra-Workflows-Quickstart, the workspace name is "Terra-Workflows-Quickstart"
workspace_namespace | A string with the workpsace name. e.g, if the workspace URL is https://anvil.terra.bio/#workspaces/fc-product-demo/Terra-Workflows-Quickstart, the workspace namespace is "fc-product-demo"
overwrite | A boolean indicating whether existing rows in the data tables should be overwritten

The workflow returns the following outputs:

output | description
--- | ---
file_report | An HTML file with check results


## data_dictionary_report

This workflow checks TSV-formatted data files against a data dictionary (DD). The DD should be specified in the same format as a data model. 

The user must specify the following inputs:

input | description
--- | ---
data_file | Google bucket path to a TSV data file.
dd_url | A URL providing the path to the data dictionary in JSON format.
out_prefix | A prefix for the resulting HTML report.

The workflow returns the following outputs:

output | description
--- | ---
file_report | An HTML file with check results
pass_checks | a boolean value where 'true' means the data file fulfilled the minimum requirements of the data dictionary (all required columns present)


## check_md5

Workflow to run an md5sum check on a file and return OK or FAILED.
