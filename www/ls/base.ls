new Tooltip!watchElements!
lines = ig.data.skore.split "\n"
    ..shift!
    ..pop!
lines .= map ->
        [osoba, den, body, popisek] = it.split "\t"
        [year, month, day] = den.split "-"
        date = new Date!
            ..setTime 0
            ..setDate day
            ..setMonth month - 1
            ..setYear year
        body = parseFloat body.replace "," "."
        {osoba, date, body, popisek}
lines.sort (a, b) -> if a.date > b.date then 1 else -1
series_assoc =
    "Nečas":
        name: "Petr Nečas"
        desc: "Zlomovým byl pro něj rok 2010, kdy se stal předsedou ODS a vzápětí i premiérem. Řadu let působil jako místopředseda strany. Ve vládě Mirka Topolánka dostal křeslo vicepremiéra a měl na starosti ministerstvo práce a sociálních věcí. Poslancem byl od roku 1992."
        img: "necas.jpg"
        data: []
    "Nagyová":
        name: "Jana Nagyová"
        desc: "Žena, která spojuje všechny tři větve kauzy: zneužívání vojenských zpravodajů, politické trafiky a napojení na lobbisty. Před 12. červnem patřila k nejvlivnějším úředníkům v zemi, byla vrchní ředitelkou kabinetu premiéra Petra Nečase (ODS). Časem vychází najevo, že k němu má i blízký osobní vztah. Kariéru začínala jako účetní, od roku 1996 pracovala pro ODS."
        img: "nagyova.jpg"
        data: []
    "Rittig":
        name: "Ivo Rittig"
        desc: "Vlivný podnikatel a lobbista, jehož jméno figuruje v řadě kauz. Namátkou dodávky jízdenek pro pražský dopravní podnik (část zisku z prodeje končila na Panenských ostrovech), nevýhodný pronájem skladů léčiv v Nemocnici Na Homolce nebo předražené služby pro Lesy ČR. Trvalé bydliště má v Monaku. Působí ve firmě Rittig and Partners, do loňského roku ovládal společnost Prospekta Moda, která je vlastníkem franšíz na prodej zboží luxusních módních značek."
        img: "rittig.png"
        data: []
    "Kovanda":
        name: "Milan Kovanda"
        desc: "Před „kauzou Nagyová“ byl ředitelem Vojenského zpravodajství, tuto funkci zastával od listopadu 2012. V minulosti se účastnil tří misí v Afghánistánu a jedné mise v Kosovu. Dostal řadu vyznamenání, mimo jiné i medaili NATO Za službu pro mír a svobodu. Loni v květnu se stal generálmajorem."
        img: "kovanda.jpg"
        data: []
    "Fuksa":
        name: "Ivan Fuksa"
        desc: "Bývalý ministr zemědělství v Nečasově vládě, poslanec za ODS a jeden z rebelů, kteří odmítali podpořit vládní balík změn zahrnující i zvýšení dolní sazby DPH. Kabinet kvůli zákonu vsadil všechno: hlasovalo se totiž zároveň o důvěře vládě. Fuksa couvl a začátkem listopadu 2013 složil poslanecký mandát. O pár týdnů později se stal vrchním ředitelem společnosti Český Aeroholding."
        img: "fuksa.jpg"
        data: []

lines.forEach ->
    it.date_relative = it.date.getTime! - lines[0].date.getTime!
    series_assoc[it.osoba].data.push it
series = for osoba, {name, desc, img, data} of series_assoc
    {osoba, name, desc, img, data}
container = d3.select ig.containers.base
width = 650
height = 700
margin = top: 20 right: 20 bottom: 0 left: 10
svg = container.append \svg
    ..attr \width width + margin.left + margin.right
    ..attr \height height + margin.top + margin.left

canvas = svg.append \g
    ..attr \transform "translate(#{margin.left}, #{margin.top})"

x = d3.scale.sqrt!
    ..domain [0, lines[*-1].date_relative - lines[0].date_relative]
    ..range [0 width]

y = d3.scale.linear!
    ..domain [20 4]
    ..range [0 height]

line = d3.svg.line!
    ..x -> x it.date_relative
    ..y -> y it.body

symbol = d3.svg.symbol!
    ..type \circle


color = d3.scale.ordinal!
    ..range <[#e41a1c #377eb8 #4daf4a #984ea3 #ff7f00]>

seriesLines = canvas.selectAll \g.series .data series .enter!append \g
    ..attr \class \series
    ..append \path
        ..attr \class \line
        ..attr \stroke (d, i) -> color i
        ..attr \d -> line it.data
    ..selectAll \path.symbol .data (.data) .enter!append \path
        ..attr \class \symbol
        ..attr \d symbol!
        ..attr \stroke (d, i, parentI) -> color parentI
        ..attr \fill \white
        ..on \mouseover (d, i, parentI) ->
            d3.select @ .attr \fill color parentI
        ..on \mouseout (d, i, parentI) ->
            d3.select @ .attr \fill \white
        ..attr \data-tooltip (it, i, parentI) ->
            "<b>#{series[parentI].name}</b><br />
            #{it.date.getDate!}. #{it.date.getMonth! + 1}. #{it.date.getFullYear!}: #{it.popisek}"
        ..attr \transform -> "translate(#{x it.date_relative}, #{y it.body})"


legend = container.append \ul
    ..attr \class \legend
legend.selectAll \li .data series .enter!append \li
    ..append \img
        ..style \border-color (d, i) -> color i
        ..attr \src -> "http://datasklad.ihned.cz/nagyova/img/#{it.img}"
        ..on \mouseover (d, i) -> highlightLine i
        ..on \mouseout -> clearHighlight!
        ..attr \data-tooltip -> "<b>#{it.name}</b><br />#{it.desc}"

highlightLine = (index) ->
    line = seriesLines.filter (d, i) -> i == index
    line
        ..classed \active yes
        ..selectAll \path.symbol .attr \fill -> color index

clearHighlight = ->
    seriesLines
        ..classed \active no
        ..selectAll \path.symbol .attr \fill \white
