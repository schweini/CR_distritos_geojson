#!/usr/bin/perl


use XML::Hash::LX;
#use JSON;

# KML file from http://daticos-geotec.opendata.arcgis.com/datasets/741bdd9fa2ca4d8fbf1c7fe945f8c916_0

open(IN, '<kml/provincias.kml');
while ( $l = <IN> )
{
    $xml .= $l;
}

my $hash = xml2hash $xml;
$hash = $hash->{kml}->{Document}->{Folder};

@pms = @{ $hash->{Placemark} };

foreach $pm ( @pms )
{
    #use Data::Dumper;
    @data = @{ $pm->{ExtendedData}->{SchemaData}->{SimpleData} };
    foreach $data ( @data )
    {
        if ( $data->{'-name'} eq 'NPROVINCIA')
        {
            $p = $data->{'#text'};
        }
        elsif ( $data->{'-name'} eq 'COD_PROV')
        {
            $pc = $data->{'#text'};
        }
    }

    $code = $pc;
    
    print "$p : $code\n";
    
    my @polys;

    if ( ref( $pm->{MultiGeometry}->{Polygon} ) eq 'ARRAY' )
    {
        @polys = @{ $pm->{MultiGeometry}->{Polygon} };
    }
    else
    {
        @polys = ( $pm->{MultiGeometry}->{Polygon} )
    }
    
    foreach $poly (@polys)
    {
        $coords = $poly->{outerBoundaryIs}->{LinearRing}->{coordinates};
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
    }
    
    #print join(' | ', map { "$_ ".ref($hash->{$_}) } sort keys $pm->{ExtendedData})."\n";
    #print $pm->{ExtendedData};
}

use JSON;
$JSON = JSON->new();

foreach $code ( sort keys %out )
{
    $json = { 
                'type' => 'Feature', 
                'properties' => { Provincia => $out{$code}{p}, Codigo => $code },
                'geometry' => { type => MultiPolygon, coordinates => [ $out{$code}{polys} ] }
                #'geometry' => { type => Polygon, coordinates => [ $out{$code}{polys}->[0] ] }
            };
    open(OUT, ">geojson/$code.geojson");
    print OUT $JSON->pretty->encode($json);
    
}
