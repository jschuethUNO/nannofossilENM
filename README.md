# nannofossilENM

## Ecological Niche Modeling for Calcareous Nannofossils

The R code file is available for download. You will need your own data to run - eventually I want to place a "test" dataset but that has not been done yet.
Read the comments in the code to see how to run and modify as needed.
The data you have must be in a specific format for this to work.

<ol>
  <li>First column is y location or latitude</li>
  <li>Second column is x location or longitude</li>
  <li>Third column is taxon abundance </li>
  <li>Each column following is a paleoproxy variable - you can have as many of these as you'd like</li>
</ol>

The spreadsheet must be a tab-delineated text file with column labels as the first row and row labels / site names as the first column. Your proxy data can be:
<ul>
  <li>Either categorical, numerical, or both</li>
  <li>You can have as many variables as you want</li>
  <li>Different kinds of data can be mixed together</li>
</ul>

It's important to note that your taxon abundance must be in column 3, and you can only have one taxon run at a time, but as many proxy variables as you want.
