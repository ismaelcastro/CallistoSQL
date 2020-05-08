use ProelHospitalar
go
exec informativoDeVencimentos 0, '01/01/2019', '31/12/2019', null,null
ALTER procedure InformativoDeVencimentos 
@cdFilial int,
@dtVenctoInicial smalldatetime,
@dtVenctoFinal smalldatetime,
@cdCliente int,
@cdCobRec int
with ENCRYPTION AS
select
vfTituloCREAberto.cdRec,
vfTituloCREAberto.NrDoc,
vfTituloCREAberto.TpDoc,
vfTituloCREAberto.cdIndexador,
vfTituloCREAberto.cdCobRec,
vfTituloCREAberto.dtVencto,
vfTituloCREAberto.cdCliente,
vcEntcli.RazaoSocial,
vfTituloCREAberto.VlBruto,
vfTituloCREAberto.dsRec,
dbo.GetDateSH(vfTituloCREAberto.dtEmissao) as dtEmissao,
dbo.GetDateSH(GetDate()) as dtAtual,
TpDocumento.dsTpDoc,
TpCobRec.dsCobRec,
vcEntCli.emailFinanceiro,
[callisto].dbo.CalculeValorCorrigido(vfTituloCREAberto.cdMoeda, vfTituloCREAberto.cdIndexador, vfTituloCREAberto.vlBruto,
[callisto].dbo.GetDataInicialCorrecaoCRE(vfTituloCREAberto.cdRec,@cdFilial, vfTituloCREAberto.dtEmissao),
[Callisto].dbo.GetDataFinalCorrecaoCRE(vfTituloCREAberto.cdRec, @cdFilial, [callisto].dbo.GetDateSH(GetDate()))) as vlCorrigido
from [callisto].[dbo].vfTituloCREAberto
inner join [callisto].[dbo].vcEntcli ON vcEntcli.cdCliente = vfTituloCREAberto.cdCliente
inner join [Callisto].[dbo].vFilialAtiva ON vFilialAtiva.cdFilial = vfTituloCREAberto.cdFilial
left join [Callisto].[dbo].TpDocumento on TpDocumento.TpDoc = vfTituloCREAberto.TpDoc
left join [Callisto].[dbo].Moeda on Moeda.cdMoeda = vfTituloCREAberto.cdIndexador
left join [Callisto].[dbo].TpCobRec on TpCobRec.cdCobRec = vfTituloCREAberto.cdCobRec
WHERE
vfTituloCREAberto.cdFilial = @cdFilial AND
vfTituloCREAberto.dtVencto BETWEEN @dtVenctoInicial AND @dtVenctoFinal AND
((@cdCobRec IS NULL)) OR ((vfTituloCREAberto.cdCobRec = @cdCobRec)) AND
((@cdCliente is null)) or ((vfTituloCREAberto.cdCliente = @cdCliente)) 



