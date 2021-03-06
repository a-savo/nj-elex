# Import and Tidy Local Election Results

**ballotReader** is a set of functions designed to efficiently import and tidy local election results in a variety of standardized formats, including the Clarity Elections reporting platform and common `.pdf` formats. ballotReader is intended to eliminate time spent wrangling election results online, in Microsoft Excel, and in third-party conversion software by processing election data entirely within R, where it can then easily be saved as an analysis-friendly `.csv` file.

## Installation

ballotReader can be installed by running the following command in the R console:

```R
devtools::install_github("a-savo/govt496/ballotReader")
```

In order to use most ballotReader functions, users must first install the most recent version of [Java](https://java.com/en/download/) and the [Java Development Kit](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) as well as rOpenSci's [tabulizer](https://github.com/ropensci/tabulizer) package via Github.

## Code Examples

Input and output files from the following examples are saved in `/data`.

`read_results()` is the most basic ballotReader function, designed to import and tidy tables from `.pdf` files which are already well formatted. For ballotReader's purposes, a table is well formatted if localities (counties, cities, etc.) are listed in the leftmost column, candidate vote totals are listed in each subsequent column, and none of the table text is formatted vertically. For example, the following `.pdf` from the New Jersey Division of Elections website is perfectly formatted for `read_results()`:

<img src = "https://i.imgur.com/thLSu25.png" alt = "1st District General Election Results: House of Representatives" width = "700">


```R
url <- "http://www.njelections.org/2016-results/2016-municipality-hor-district1.pdf"
out <- read_results(url)
head(out, 15)
            Subgroup      Municipality                      Candidate  Votes
1  Burlington County   Maple Shade Twp Donald W. Norcross\rDemocratic   4025
2  Burlington County      Palmyra Boro Donald W. Norcross\rDemocratic   1975
3   Federal Overseas Burlington Totals Donald W. Norcross\rDemocratic   6000
4      Camden County      Audubon Boro Donald W. Norcross\rDemocratic   2409
5      Camden County Audubon Park Boro Donald W. Norcross\rDemocratic    288
6      Camden County   Barrington Boro Donald W. Norcross\rDemocratic   1733
7      Camden County     Bellmawr Boro Donald W. Norcross\rDemocratic   2649
8      Camden County       Berlin Boro Donald W. Norcross\rDemocratic   1591
9      Camden County       Berlin Twp. Donald W. Norcross\rDemocratic   1293
10     Camden County    Brooklawn Boro Donald W. Norcross\rDemocratic    455
11     Camden County       Camden City Donald W. Norcross\rDemocratic  16424
12     Camden County  Cherry Hill Twp. Donald W. Norcross\rDemocratic  20655
13     Camden County  Chesilhurst Boro Donald W. Norcross\rDemocratic    476
14     Camden County    Clementon Boro Donald W. Norcross\rDemocratic   1126
15     Camden County Collingswood Boro Donald W. Norcross\rDemocratic   4581
```

`read_results()` also contains a `merged_header` argument, which allows .pdf tables with merged headers grouping candidates or races together [(example)](http://www.njelections.org/2017-results/2017-general-election-results-gen-assembly-state-senate-district-01.pdf) to be imported.


`read_vertical_results()` is designed to import and tidy otherwise well-formatted .pdf tables where column names are formatted vertically for a single race of interest. Because the `tabulizer` package struggles to correctly interpret vertically-oriented text, the column names must be provided manually. The page range must also be specified for the race of interest. `read_vertical_results()` is designed to import results from `.pdf` files like the following example from the Essex County Clerk's Office in New Jersey:

<img src = "https://i.imgur.com/v0VD0dA.png" alt = "2017 Official Primary Election Results - Democratic for Governor" width = "700">

```R
url <- "http://www.essexclerk.com/_Content/pdf/ElectionResult/DEM_SOV_2017.pdf"
out <- read_vertical_results(url, range = c(1:11), 
                                  colnames = c("Municipality","Registration","Ballots Cast","Turnout (%)",
                                               "Philip MURPHY","William BRENNAN","John S. WISNIEWSKI",
                                               "Jim Johnson","Mark ZINNA","Raymond J. LESNIAK","Write-In"))
head(out, 15)
                    Municipality  Vote Choice Votes
1  Belleville 1-1 - Election Day Registration   427
2  Belleville 1-2 - Election Day Registration   412
3  Belleville 1-3 - Election Day Registration   305
4  Belleville 1-4 - Election Day Registration   356
5  Belleville 1-5 - Election Day Registration   383
6  Belleville 1-6 - Election Day Registration   218
7  Belleville 2-1 - Election Day Registration   270
8  Belleville 2-2 - Election Day Registration   191
9  Belleville 2-3 - Election Day Registration   290
10 Belleville 2-4 - Election Day Registration   302
11 Belleville 2-5 - Election Day Registration   314
12 Belleville 2-6 - Election Day Registration   265
13 Belleville 2-7 - Election Day Registration   268
14 Belleville 2-8 - Election Day Registration   411
15 Belleville 3-1 - Election Day Registration   323
```

`read_clarity_results()` is ballotReader's most powerful function, designed to download and process election reports from local election websites that use Scytl's Clarity Elections platform. `read_clarity_results()` downloads and unzips summary `.csv` reports and detailed `.xls`, `.xml`, and `.txt` reports from Clarity Elections websites, and can also import and tidy detailed precinct-level election results, creating a list of data.frames containing data from each worksheet in the `detail.xls` report.

`read_clarity_results()` contains six important arguments:
* `file` should be a link to either the website's home page (if Web01) or a direct link to the desired `.zip` file (if Web02). See below for the difference between Web01 and Web02.
* `directory` is the directory where the report will be unzipped and loaded from.
* `filename` is the file name for the report, including the file extension (i.e. `.csv`, `.xls`, `.xml`, `.txt`). This is set to NULL by default, but it is recommended to use unique names for each report if you plan to download multiple reports, as Clarity Elections websites use the same default report names for each site.
* `report` is only used for Web01 sites. Pick from "csv", "xls", "xml", or "txt".
* `tidy_detail` is FALSE by default. Set `tidy_detail` to TRUE in order to import and tidy precinct-level election results from the `detail.xls` report. Be aware that this part of the function can take a long time to run for large reports with many elections.
* `page_range` is only used if `tidy_detail` is TRUE. Set `page_range` to a numeric vector from 3 to n (i.e. `3:n`) to only import and tidy a subset of the `detail.xls` report. Users may want to run `read_clarity_results()` with `tidy_detail` set to FALSE at first in order to determine how many pages to import.

<img src = "https://i.imgur.com/BPFuOJS.jpg" alt = "Web01: Gloucester County, left        Web02: Essex County, right" width = "700">


Clarity Elections websites generally come in one of two formats, Web01 and Web02. The site format is included in the URL and can also be determined by the site's formatting. Web01 formats (left, Gloucester County, NJ) do not provide direct links to `.zip` files, while Web02 formats (right, Essex County, NJ) do provide direct links, highlighted in the bottom right. Use the home page for Web01 sites and the direct link for Web02 sites.

Web01:
```R
url <- "http://results.enr.clarityelections.com/NJ/Gloucester/71871/191307/Web01/en/summary.html"
out <- read_clarity_results(url, directory = "data/", filename = "gloucester.xls", report = "xls", tidy_detail = TRUE, page_range = 3:5)
head(out[[1]], 15)
                    Race Candidate         Vote Type            Locality Votes
1  Governor (Vote For 1)           Registered Voters  Clayton District 1   845
2  Governor (Vote For 1)                       Total  Clayton District 1   290
3  Governor (Vote For 1)           Registered Voters  Clayton District 2   819
4  Governor (Vote For 1)                       Total  Clayton District 2   232
5  Governor (Vote For 1)           Registered Voters  Clayton District 3  1183
6  Governor (Vote For 1)                       Total  Clayton District 3   386
7  Governor (Vote For 1)           Registered Voters  Clayton District 4  1066
8  Governor (Vote For 1)                       Total  Clayton District 4   315
9  Governor (Vote For 1)           Registered Voters  Clayton District 5   750
10 Governor (Vote For 1)                       Total  Clayton District 5   197
11 Governor (Vote For 1)           Registered Voters  Clayton District 6  1017
12 Governor (Vote For 1)                       Total  Clayton District 6   357
13 Governor (Vote For 1)           Registered Voters Deptford District 1   956
14 Governor (Vote For 1)                       Total Deptford District 1   302
15 Governor (Vote For 1)           Registered Voters Deptford District 2  1064
```

Web02:
```R
url <- "http://results.enr.clarityelections.com/NJ/Essex/72004/191383/reports/detailxls.zip"
out <- read_clarity_results(url, directory = "data/", filename = "essex.xls", tidy_detail = TRUE, page_range = 3:5)
head(out[[1]], 15)
                                       Race Candidate         Vote Type       Locality Votes
1  For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-1   901
2  For Governor / Lt. Governor (Vote For 1)                       Total Belleville 1-1   224
3  For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-2   988
4  For Governor / Lt. Governor (Vote For 1)                       Total Belleville 1-2   264
5  For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-3   816
6  For Governor / Lt. Governor (Vote For 1)                       Total Belleville 1-3   207
7  For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-4   922
8  For Governor / Lt. Governor (Vote For 1)                       Total Belleville 1-4   279
9  For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-5   845
10 For Governor / Lt. Governor (Vote For 1)                       Total Belleville 1-5   214
11 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-6   610
12 For Governor / Lt. Governor (Vote For 1)                       Total Belleville 1-6   174
13 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 2-1   662
14 For Governor / Lt. Governor (Vote For 1)                       Total Belleville 2-1   179
15 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 2-2   528
```

`get_totals()` and `drop_totals()` are helper functions that filter a data.frame to either contain or drop any rows which contain vote totals. This can be useful depending on which subset of data the user is interested in.

```R
essex_gov_17 <- read.csv("data/essex_gov_17.csv")
totals <- get_totals(essex_gov_17)
no_totals <- drop_totals(essex_gov_17)

head(totals)
                                      Race Candidate Vote.Type       Locality Votes
1 For Governor / Lt. Governor (Vote For 1)               Total Belleville 1-1   224
2 For Governor / Lt. Governor (Vote For 1)               Total Belleville 1-2   264
3 For Governor / Lt. Governor (Vote For 1)               Total Belleville 1-3   207
4 For Governor / Lt. Governor (Vote For 1)               Total Belleville 1-4   279
5 For Governor / Lt. Governor (Vote For 1)               Total Belleville 1-5   214
6 For Governor / Lt. Governor (Vote For 1)               Total Belleville 1-6   174

head(no_totals)
                                      Race Candidate         Vote.Type       Locality Votes
1 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-1   901
2 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-2   988
3 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-3   816
4 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-4   922
5 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-5   845
6 For Governor / Lt. Governor (Vote For 1)           Registered Voters Belleville 1-6   610
```

## Notes

* If you find a bug or have ideas for improvements, feel free to shoot me an email at alyssa.g.savo@gmail.com
* You can also modify the functions in this package to use on other formats where needed
* License: GPL-3

### Todo

* Add functionality so that `read_` functions can take in a list of URLs/docs
* Develop `separate_party()` to separate political party from the candidate column where appropriate
* Add more helper functions as appropriate
* `read_results()` should be able to create a list of elections for documents that contain multiple elections, as `return_clarity_results()` does
* `read_vertical_results()` should be able to handle a second non-vote column
* `read_vertical_results()` should automatically retrieve and build column names
* Tweak `read_clarity_results()` to decrease load time
* Construct a read function for two-column summary reports [(example)](http://www.camdencounty.com/wp-content/uploads/files/2016%20CamCo%20General%20Election%20Canvasser.pdf)
