use strict;
use CXGN::Tools::File;
use CXGN::Page;
use CXGN::VHost;

my $vhost_conf=CXGN::VHost->new();
my $page=CXGN::Page->new('Secretom','john');
$page->header('Secretom');
print<<END_HTML;
<div style="width:100%; color:#303030; font-size: 1.1em; text-align:left;">

<center>
<img style="margin-bottom:10px" src="/documents/img/secretom/secretom_logo_smaller.jpg" alt="secretom logo" />
</center>

<br />
<span style="white-space:nowrap; display:block; padding:3px; background-color: #fff; text-align:center; color: #444; font-size:1.3em">
Computational prediction of secreted proteins
</span>
<br />

<p>The primary route for protein secretion from eukaryotic cells is termed the classical, or endoplasmic reticulum (ER)/Golgi-dependent, secretory pathway. Briefly, secreted eukaryotic proteins utilize an N-terminal signal peptide (SP) to direct their co-translation into the ER lumen, after which they progress through the endomembrane system and are ultimately exported to the extracellular environment, or cell surface. It should be noted that these represent a subset of SP-containing proteins, since others are retained in the ER or Golgi or are redirected to other compartments, such as the vacuole.</p>

<center><img src="/documents/img/secretom/pathways.png"></center>

<p>A number of <a href="#tools">computational tools have been developed</a> to predict the presence of SPs. These programs have been greatly refined in recent years and their accuracy has improved with the adoption of machine learning algorithms. However, while this is a valuable approach, as with all prediction-based tools, there is a consistent error rate and both false positive and negative predictions should be expected. One of our major goals is to identify the incorrect predictions and generate a database of computationally and functionally confirmed secreted plant proteins. It has been reported that one of the most effective predictors of SPs is <a href="http://www.cbs.dtu.dk/services/SignalP">SignalP 3.0</a>. We have used this to screen the predicted proteomes of several plant species to date: </p>

<table align="center">
<tr>
<td align="center"><a href="ftp://ftp.sgn.cornell.edu/secretom/Tair8.pep.1.sptp.fasta"><strong><em>Arabidopsis thaliana</em></strong></a></td>
<td align="center"><a href="ftp://ftp.sgn.cornell.edu/secretom/Rice.pep.1.sptp.fasta"><strong>Rice (<em>Oryza sativa</em>)</a></strong></td>
<td align="center"><a href="ftp://ftp.sgn.cornell.edu/secretom/Brachy.pep.1.sptp.fasta"><strong><em>Brachypodium distachyon</em></strong></a></td>
<td align="center"><a href="ftp://ftp.sgn.cornell.edu/secretom/ITAG1.pep.sptp.fasta"><strong><em>Solanum lycopersicum</em></strong></a></td>
</tr>
<td><img src="/documents/img/secretom/arabidopsisthaliana.png"></td>
<td><img src="/documents/img/secretom/oryzasativa.png"></td>
<td><img src="/documents/img/secretom/brachypodiumdistachyon.png"></td>
<td><img src="/documents/img/secretom/solanumlycopersicum.png"></td>
</tr>
<tr><td colspan="4" align="center"><a href="search.pl" class="boxbgcolor5"><b>SEARCH</b></a></td></tr>
</table>

<br /><br />

<a name="tools"><strong>Computational tools for prediction of ER-targeting signal peptides</strong></a>
<ul>
<li><a href="http://www.cbs.dtu.dk/services/SignalP">SignalP</a></li>
<li><a href="http://www.predisi.de">PrediSi</a></li>
<li><a href="http://rpsp.bioinfo.pl/">Rapid Prediction of Signal Peptides (RPSP)</li>
<li><a href="http://phobius.sbc.su.se/">Phobius</a></li>
<li><a href="http://urgi.versailles.inra.fr/predotar/predotar.html">Predotar</a></li>
</ul>

</div>

END_HTML

$page->footer();
