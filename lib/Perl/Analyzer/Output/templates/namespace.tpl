<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="bootstrap.min.css" rel="stylesheet">
    <style type="text/css">
        body { padding-top: 110px; }
        section {
            padding-top:110px;
            margin-top:-110px;
        }
        .p-title {
            margin: 0px;
        }
    </style>
    <? my $stash = $_[0]; ?>
    <title><?= $stash->{'namespace'} || '~' ?></title>
    </head>
  <body>
    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container">
            <h1><?= $stash->{'namespace'} || '~' ?></h1>
        </div>
    </nav>
    
    <div class="container">
        <div class="panel panel-default">
        <div class="panel-body">
            <ul class="list-unstyled">
            <? if ($stash->{'namespace'}) { ?>
                <li><strong><a href="<?= _ns_filename($stash->{'parent_namespace'}) ?>">..</a></strong></li>
            <? } ?>
            <? for my $ns (@{$stash->{'namespaces'}}) { ?>
                <li><strong><a href="<?= _ns_filename($ns) ?>"><?= $ns ?></a></strong></li>
            <? } ?>
            <? for my $m (@{$stash->{'packages'}}) { ?>
                <li><a href="<?= _pkg_filename($m) ?>"><?= $m ?></a></li>
            <? } ?>
            </ul>
        </div>
        </div>
    </div>
  </body>
</html>