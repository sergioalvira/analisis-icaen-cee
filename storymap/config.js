var config = {
    style: 'mapbox://styles/sergioalvira/cmbgw7p4w008501se1pa87425',
    // leave commented to use Mapbox Standard Style
    accessToken: 'pk.eyJ1Ijoic2VyZ2lvYWx2aXJhIiwiYSI6ImNtYmZvYzIzOTBoaGsya3NobjJ0OGppd2wifQ.Q4on3FShQbHhhxpxg7TmaA',
    showMarkers: false,
    markerColor: '#3FB1CE',
    //projection: 'equirectangular',
    //Read more about available projections here
    //https://docs.mapbox.com/mapbox-gl-js/example/projections/
    inset: false,
    insetOptions: {
        markerColor: 'orange'
    },
    insetPosition: 'bottom-right',
    theme: 'dark',
    use3dTerrain: false, //set true for enabling 3D maps.
    auto: false,
    title: 'Certificación energética de los edificios de Barcelona',
    subtitle: 'Representación de la cualificación según emisiones de CO2 en una escala de la A a la G',
    byline: 'Elaborado por Sergio Alvira Sanz',
    footer: 'Elaborado con datos del <a href="https://analisi.transparenciacatalunya.cat/Energia/Certificats-d-efici-ncia-energ-tica-d-edificis/j6ii-t3w2/about_data" target="_blank">registro de Certificados de Eficiencia Energética</a> del ICAEN <br> Created using <a href="https://github.com/mapbox/storytelling" target="_blank">Mapbox Storytelling</a> template.',
    chapters: [
        {
            id: '1',
            hidden: true,
            location: {
                center: [2.16403, 41.39939],
                zoom: 11.61,
                pitch: 45.50,
                bearing: -45.60
            },
            mapAnimation: 'flyTo',
            rotateAnimation: false,
            callback: '',
            onChapterEnter: [
                // {
                //     layer: 'layer-name',
                //     opacity: 1,
                //     duration: 5000
                // }
            ],
            onChapterExit: [
                // {
                //     layer: 'layer-name',
                //     opacity: 0
                // }
            ]
        },
        {
            id: '2',
            alignment: 'left',
            hidden: false,
            description: 'En la ciudad de Barcelona encontramos zonas que presentan más densidad de edificios certificados, como por ejemplo el barrio de Vila de Gràcia...',
            location: {
                center: [2.15767, 41.40614],
                zoom: 14.15,
                pitch: 0,
                bearing: 0,
                // flyTo additional controls-
                // These options control the flight curve, making it move
                // slowly and zoom out almost completely before starting
                // to pan.
                //speed: 2, // make the flying slow
                //curve: 1, // change the speed at which it zooms out
            },
            mapAnimation: 'flyTo',
            rotateAnimation: false,
            callback: '',
            onChapterEnter: [],
            onChapterExit: []
        },
        {
            id: '3',
            alignment: 'left',
            hidden: false,
            description: '... o el Poble Sec.',
            location: {
                center: [2.15793, 41.37287],
                zoom: 14.15,
            },
            mapAnimation: 'flyTo',
            rotateAnimation: false,
            callback: '',
            onChapterEnter: [],
            onChapterExit: []
        },
        {
            id: '4',
            alignment: 'left',
            hidden: false,
            description: 'Para encontrar clústeres de edificios con una certificación de A o B debemos acudir a zonas como el Guinardó...',
            location: {
                center: [2.17334, 41.41628],
                zoom: 15.06,
                pitch: 25,
                bearing: -43.20
            },
            mapAnimation: 'flyTo',
            rotateAnimation: false,
            callback: '',
            onChapterEnter: [],
            onChapterExit: []
        },
        {
            id: '5',
            alignment: 'left',
            hidden: false,
            description: '... o Poble Nou.',
            location: {
                center: [2.20749, 41.39951],
                zoom: 15.06,
                pitch: 20.42,
                bearing: -77.22
            },
            mapAnimation: 'flyTo',
            rotateAnimation: false,
            callback: '',
            onChapterEnter: [],
            onChapterExit: []
        },
        {
            id: '6',
            alignment: 'right',
            hidden: false,
            description: 'En general los edificios de Barcelona tienen a una cualificación de emisiones de CO2 de E o F, y es complicado apreciar patrones espaciales, especialmente por el reducido número de edificios que cuentan con CEE.',
            location: {
                center: [2.19567, 41.42349],
                zoom: 11.74,
                pitch: 0,
                bearing: -45
            },
            mapAnimation: 'flyTo',
            rotateAnimation: false,
            callback: '',
            onChapterEnter: [],
            onChapterExit: []
        }
    ]
};
