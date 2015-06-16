<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="bootstrap.min.css" rel="stylesheet">
    <? my $offset = 180; ?>
    <style type="text/css">
        body { padding-top: <?= $offset ?>px; }
        section {
            padding-top:<?= $offset ?>px;
            margin-top:-<?= $offset ?>px;
            z-index: -9999;
            width: 1px;
        }
        .p-title {
            margin: 0px;
        }


        /* diagram */ 
        .node_parent circle {
            fill: #fff;
            stroke: #990000;
            stroke-width: 3px;
        }
        .node_use circle {
            fill: #fff;
            stroke: steelblue;
            stroke-width: 3px;
        }
        .node_current circle {
            fill: #990000;
            stroke: #990000;
            stroke-width: 3px;
        }
        .node text { font: 14px sans-serif }
        .link {
            fill: none;
            stroke: #ccc;
            stroke-width: 2px;
        }

    </style>
    <script src="d3.min.js"></script>
    <script src="draw_tree.js"></script>
    <? my $stash = $_[0]; ?>
    <? my $package = $stash->{'data'}->{ $stash->{'package'} }; ?>
    <title><?= $stash->{'package'} ?></title>
    </head>
  <body>
    <? my $has_inheritance_tree = scalar @{$package->{'parent_list'}} > 1 ? 1 : 0; ?>
    <? my $has_dependencies = scalar @{$package->{'depends_on'}} ? 1 : 0; ?>
    <? my $has_package_methods = scalar @{$package->{'methods'}} ? 1 : 0; ?>
    <? my $has_inherited_methods = scalar @{$package->{'methods_inherited'}} ? 1 : 0; ?>
  
    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container">

        <ol class="breadcrumb">
            <? for my $ns ('', @{$package->{'namespaces'}}) { ?>
            <li><a href="<?= _ns_filename($ns) ?>"><?= $ns || '~' ?></a></li>
            <? } ?>
        </ol>

            <h1><?= $stash->{'package'} ?></h1>
            <ul class="list-inline">
            <li><a href="#details" class="btn btn-default btn-xs">Details</a></li>
            <? if ($has_inheritance_tree) { ?>
                <li><a href="#inheritance" class="btn btn-default btn-xs">Inheritance tree</a></li>
                <li><a href="#parent_package" class="btn btn-default btn-xs">Parent packages</a></li>
            <? } ?>
            <? if ($has_dependencies) { ?><li><a href="#used_package" class="btn btn-default btn-xs">Used packages</a></li><? } ?>
            <? if ($has_package_methods) { ?><li><a href="#package_methods" class="btn btn-default btn-xs">Package methods</a></li><? } ?>
            <? if ($has_inherited_methods) { ?><li><a href="#inherited_methods" class="btn btn-default btn-xs">Inherited methods</a></li><? } ?>
            </ul>
        </div>
    </nav>

    <div class="container">
        <div class="panel panel-default">
        <div class="panel-heading"><h3 class="p-title">Details <section id="details"></section></h3></div>
        <div class="panel-body">
        <table class="table table-condensed">
            <tr>
            <td>Filename</td>
            <td><?= $package->{'filerootdir'} ?><strong><?= $package->{'filename'} ?></strong></td>
            </tr>
            <tr>
            <td>Line count</td>
            <td><?= $package->{'line_count'} ?></td>
            </tr>
            <tr>
            <td>Method count</td>
            <td><?= scalar @{$package->{'methods'}} ?></td>
            </tr>
            <tr>
            <td>Dependency count</td>
            <td><?= scalar @{$package->{'depends_on'}} ?></td>
            </tr>
        </table>
        </div>
        </div>
        
        <? if ($has_inheritance_tree) { ?>
        <div class="panel panel-default">
        <div class="panel-heading"><h3 class="p-title">Inheritance tree <section id="inheritance"></section></h3></div>
        <div class="panel-body" style="overflow: auto;">
            <div id="inheritance_tree" >
            <script>
            var tree_data = <?= $stash->{'inheritance_tree_json'} ?>
            var tree_data_json = tree_data[0];
            
            var mlen   = <?= $stash->{'inheritance_tree_sizes'}->{'maxlength'} ?>;
            var mchld  = <?= $stash->{'inheritance_tree_sizes'}->{'maxchild'} ?>;
            var tdepth = <?= $stash->{'inheritance_tree_sizes'}->{'depth'} ?>;

            </script>
            </div>
        </div>
        </div>

        <div class="panel panel-default">
        <div class="panel-heading"><h3 class="p-title">Parent packages <section id="parent_packages"></section></h3></div>
        <div class="panel-body">
            <ul class="list-unstyled">
            <? for my $p (@{$package->{'parent_list'}}) { ?>
                <li><? if (exists $stash->{'data'}->{$p}) { ?><a href="<?= _pkg_filename($p) ?>"><?= $p ?></a><? } else { ?><?= $p ?><? }?></li>
            <? } ?>
            </ul>
        </div>
        </div>


        <? } ?>


        <? if ($has_dependencies) { ?>
        <div class="panel panel-default">
        <div class="panel-heading"><h3 class="p-title">Used packages <section id="used_packages"></section></h3></div>
        <div class="panel-body">
            <ul class="list-unstyled">
            <? for my $p (@{$package->{'depends_on'}}) { ?>
                <li><? if (exists $stash->{'data'}->{$p}) { ?><a href="<?= _pkg_filename($p) ?>"><?= $p ?></a><? } else { ?><?= $p ?><? }?></li>
            <? } ?>
            </ul>
        </div>
        </div>
        <? } ?>
        
        
        <div class="panel panel-default">
        <div class="panel-heading"><h3 class="p-title">Methods</h3></div>
        <div class="panel-body">
        <table class="table table-condensed">
        <? if ($has_package_methods) { ?>
            <tr>
            <th colspan="2" class="active"><h4>Package methods <section id="package_methods"></section></h4></th>
            </tr>
            <tr>
            <th class="active">Name</th>
            <th class="active">Redefined from</th>
            </tr>
            <? for my $method (@{$package->{'methods'}}) { ?>
            <? my $is_redefined = scalar @{$package->{'methods_hier'}->{$method}} ? 1 : 0 ?>
            <tr>
                <td style="width:15%">
                <strong>
                <? if ($is_redefined) {?>
                    <em><?= $method ?></em>
                <? } else { ?>
                    <?= $method ?>
                <? } ?>
                </strong>
                </td>
                <td>
                <? if ($is_redefined) { ?>
                    <ul class="list-unstyled">
                        <? for my $pkg (@{$package->{'methods_hier'}->{$method}}) { ?>
                        <li><a href="<?= _pkg_filename($pkg) ?>"><?= $pkg ?></a></li>
                        <? } ?>
                    </ul>
                <? } ?>
                </td>
            </tr>
            <? } ?>
        <? } ?>
        <? if ($has_inherited_methods) { ?>
            <tr>
            <th colspan="2" class="active"><h4>Inherited methods <section id="inherited_methods"></section></h4></th>
            </tr>
            <tr>
            <th class="active">Name</th>
            <th class="active">Inherited from</th>
            </tr>
            <? for my $method (@{$package->{'methods_inherited'}}) { ?>
            <tr>
                <td style="width:15%">
                    <em><?= $method ?></em>
                </td>
                <td>
                    <ul class="list-unstyled">
                        <? for my $pkg (@{$package->{'methods_hier'}->{$method}}) { ?>
                        <li><a href="<?= _pkg_filename($pkg) ?>"><?= $pkg ?></a></li>
                        <? } ?>
                    </ul>
                   </td>
            </tr>
            <? } ?>
        <? } ?>
        </table>
        </div>
        </div>

    </div>
  </body>
</html>