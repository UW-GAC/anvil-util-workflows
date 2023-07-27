# anvil-util-workflows

Workflows for checking files in AnVIL

The workflows are written in the Workflow Description Language ([WDL](https://docs.dockstore.org/en/stable/getting-started/getting-started-with-wdl.html)). This GitHub repository contains the Dockerfile, the WDL code, and a JSON file containing inputs to the workflow, both for testing and to serve as an example.

The Dockerfile creates a docker image containing the AnvilDataModels R package and R script to generate the report. This image is built in layers, starting from an AnVIL-maintained image with the Bioconductor "AnVIL" package installed. The first layer contains the AnVILDataModels R package and is available at [uwgac/anvildatamodels](https://hub.docker.com/r/uwgac/anvildatamodels). The second layer contains the R scripts in this repository and is available on Docker Hub as
[uwgac/anvil-util-workflows](https://hub.docker.com/r/uwgac/anvil-util-workflows).


## validate_data_model

Workflow to validate TSV files against a data model using the [AnvilDataModels](https://github.com/UW-GAC/AnvilDataModels) package. An uploader will prepare files in tab separated values (TSV) format, with one file for each data table in the model, and upload them to an AnVIL workspace. This workflow will compare those files to the data model, and generate an HTML report describing any inconsistencies. 

If the data model specifies that any columns be auto-generated from other columns, the workflow generates TSV files with updated tables before running checks.

This workflow checks whether expected tables (both required and optional) are included. For each table, it checks column names, data types, and primary keys. Finally, it checks foreign keys (cross-references across tables). Results of all checks are displayed in an HTML file.

If miminal checks are passed and `import_tables` is set to `true`, the workflow will then import the files as data tables in an AnVIL workspace. If checks are not passed, the workflow will fail and the user should review the file "data_model_validation.html" in the workflow output directory.

The user must specify the following inputs:

input | description
--- | ---
table_files | This input is of type Map[String, File], which consists of key:value pairs. Keys are table names, which should correspond to names in the data model, and values are Google bucket paths to TSV files for each table.
model_url | A URL providing the path to the data model in JSON format.
hash_id_nchar | Number of characters in auto-generated columns (default 16)
import_tables | A boolean indicating whether tables should be imported to a workspace after validation.
overwrite | A boolean indicating whether existing rows in the data tables should be overwritten.
workspace_name | A string with the workspace name. e.g, if the workspace URL is https://anvil.terra.bio/#workspaces/fc-product-demo/Terra-Workflows-Quickstart, the workspace name is "Terra-Workflows-Quickstart"
workspace_namespace | A string with the workspace name. e.g, if the workspace URL is https://anvil.terra.bio/#workspaces/fc-product-demo/Terra-Workflows-Quickstart, the workspace namespace is "fc-product-demo"

The workflow returns the following outputs:

output | description
--- | ---
validation_report | An HTML file with validation results
tables | A file array with the tables after adding auto-generated columns. This output is not generated if no additional columns are specified in the data model.


## data_model_report

Workflow to validate TSV files against a data model using the [AnvilDataModels](https://github.com/UW-GAC/AnvilDataModels) package. An uploader will prepare files in tab separated values (TSV) format, with one file for each data table in the model, and upload them to an AnVIL workspace. This workflow will compare those files to the data model, and generate an HTML report describing any inconsistencies.

This workflow checks whether expected tables (both required and optional) are included. For each table, it checks column names, data types, and primary keys. Finally, it checks foreign keys (cross-references across tables). Results of all checks are displayed in an HTML file.

If the data model specifies that any columns be auto-generated from other columns, the workflow returns TSV files with updated tables. The user can then use the data_table_report workflow to import these tables to an AnVIL workspace.

The user must specify the following inputs:

input | description
--- | ---
table_files | This input is of type Map[String, File], which consists of key:value pairs. Keys are table names, which should correspond to names in the data model, and values are Google bucket paths to TSV files for each table.
model_url | A URL providing the path to the data model in JSON format.

The workflow returns the following outputs:

output | description
--- | ---
validation_report | An HTML file with validation results
tables | A file array with the tables after adding auto-generated columns. These tables can be imported into an AnVIL workspace as data tables. This output is not generated if no additional columns are specified in the data model.
pass_checks | a boolean value where 'true' means the set of tables fulfilled the minimum requirements of the data model (all required tables/columns present)


## data_table_import

This workflow imports TSV files into AnVIL data tables. If 'validate' is true, tt does the same checks as data_model_report before import, and fails if minimum checks are not passed.

The user must specify the following inputs:

input | description
--- | ---
table_files | This input is of type Map[String, File], which consists of key:value pairs. Keys are table names, which should correspond to names in the data model, and values are Google bucket paths to TSV files for each table.
model_url | A URL providing the path to the data model in JSON format.
validate | A boolean indicating whether to run a validation step before import
overwrite | A boolean indicating whether existing rows in the data tables should be overwritten
workspace_name | A string with the workspace name. e.g, if the workspace URL is https://anvil.terra.bio/#workspaces/fc-product-demo/Terra-Workflows-Quickstart, the workspace name is "Terra-Workflows-Quickstart"
workspace_namespace | A string with the workspace name. e.g, if the workspace URL is https://anvil.terra.bio/#workspaces/fc-product-demo/Terra-Workflows-Quickstart, the workspace namespace is "fc-product-demo"

The workflow returns the following outputs:

output | description
--- | ---
validation_report | An HTML file with validation results



## data_dictionary_report

This workflow checks TSV-formatted data files against a data dictionary (DD). The DD should be specified in the same format as a data model. 

The user must specify the following inputs:

input | description
--- | ---
data_file | Google bucket path to a TSV data file.
dd_url | A URL providing the path to the data dictionary in JSON format.

The workflow returns the following outputs:

output | description
--- | ---
validation_report | A text file with validation results
pass_checks | a boolean value where 'true' means the data file fulfilled the minimum requirements of the data dictionary (all required columns present)


## check_md5

Workflow to compare the md5sum in google cloud storage with a
user-provided value. Three scenarios are possible:

1. The md5sums match. The workflow succeds with return value PASS.
2. The md5sums do not match. The workflow fails.
3. There is no md5sum available for the file in Google cloud storage,
   because it was uploaded with a composite or multipart upload. The
   workflow succeeds with return value UNVERIFIED.

The user must specify the following inputs:

input | description
--- | ---
file | Google bucket path to a file.
md5sum | String with expected md5sum.
project_id | Google project id to bill for checking files in requester_pays buckets.

The workflow returns the following outputs:

output | description
--- | ---
md5_check | String with results of check (PASS, FAIL, or UNVERIFIED)
