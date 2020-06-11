


use XML::Hash::LX;
#use JSON;

open(IN, '<distritos.kml');
while ( $l = <IN> )
{
    $xml .= $l;
}

my $hash = xml2hash $xml;
$hash = $hash->{kml}->{Document}->{Folder};

@pms = @{ $hash->{Placemark} };

foreach $pm ( @pms )
{
    use Data::Dumper;
    @data = @{ $pm->{ExtendedData}->{SchemaData}->{SimpleData} };
    foreach $data ( @data )
    {
        if ( $data->{'-name'} eq 'NOM_PROV')
        {
            $p = $data->{'#text'};
        }
        elsif ( $data->{'-name'} eq 'NOM_CANT')
        {
            $c = $data->{'#text'};
        }
        elsif ( $data->{'-name'} eq 'NOM_DIST')
        {
            $d = $data->{'#text'};
        }
        elsif ( $data->{'-name'} eq 'CODIGO')
        {
            $code = $data->{'#text'};
            if ( $code =~ /^(\d\d\d)(\d)$/ )
            {
                $code = $1.'0'.$2;
            }
        }
    }
    
    print "$p - $c - $d: $code\n";
    $coords = $pm->{Polygon}->{outerBoundaryIs}->{LinearRing}->{coordinates};
    @coords = split(/\s/, $coords);
    

    my @latlon;
    foreach $coord ( @coords )
    {
        ($lon,$lat) = split(/,/, $coord);
        $lat += 0;
        $lon += 0;
        #push @latlon, [$lat, $lon];
        push @latlon, [$lon, $lat];
    }
    
    $out{$code}{p} = $p;
    $out{$code}{c} = $c;
    $out{$code}{d} = $d;
    push @{ $out{$code}{polys} }, \@latlon;

    #print join(' | ', map { "$_ ".ref($hash->{$_}) } sort keys $pm->{ExtendedData})."\n";
    #print $pm->{ExtendedData};
}

use JSON;
$JSON = JSON->new();

foreach $code ( sort keys %out )
{
    $json = { 
                'type' => 'Feature', 
                'properties' => { Provincia => $out{$code}{p}, Canton => $out{$code}{c}, Distrito => $out{$code}{d}, Codigo => $code },
                'geometry' => { type => MultiPolygon, coordinates => [ $out{$code}{polys} ] }
                #'geometry' => { type => Polygon, coordinates => [ $out{$code}{polys}->[0] ] }
            };
    open(OUT, ">geojson/$code.geoJSON");
    print OUT $JSON->pretty->encode($json);
    
}
