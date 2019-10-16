select Tit.NrDoc, NF.cdPed, Tit.NF, Tit.dtEmissao, Tit.dtVencto, Tit.TpDoc, CONCAT(Cli.cdCliente,' - ',Cli.nmEntCli) AS cliente,
Cli.Fone1, Tit.VlBruto, Tit.VlDesc,Tit.VlPago AS 'VL.Líquido',  COB.dsCobRec, Tit.cdEstagioCob, Tit.Status
from vfTituloCRE AS Tit with(nolock) 
INNER JOIN vcEntcli AS Cli ON Tit.cdCliente = Cli.cdCliente
LEFT OUTER JOIN vfNotaCRE AS NF with(nolock) ON Tit.NF = NF.cdNf
LEFT OUTER JOIN TpCobRec AS COB with(nolock) ON Tit.cdCobRec = COB.cdCobRec
WHERE Tit.dtVencto BETWEEN '01/09/2019' and '30/09/2019'
AND Tit.cdFilial = 0
ORDER BY Tit.cdCliente asc;


--Titulos à receber 
SELECT SUM(Tit.VlBruto) FROM vfTituloCRE AS Tit
INNER JOIN BaixaRecTit AS Baixat ON Tit.cdRec = Baixat.cdRec
INNER JOIN BaixaRec AS BaixaR ON Baixat.cdBordRec = BaixaR.cdBordRec
WHERE Tit.dtVencto BETWEEN '2019-09-01' AND '2019/09/30'
AND BaixaR.fDevolucao != 'S'
AND Baixat.Status != 'C'
AND Tit.cdFilial = 0;
-- Titulos recebidos
SELECT SUM(Tit.VlBruto) as 'Total Recebido' FROM vfTituloCRE AS Tit
INNER JOIN BaixaRecTit AS Baixat ON Tit.cdRec = Baixat.cdRec
INNER JOIN BaixaRec AS BaixaR ON Baixat.cdBordRec = BaixaR.cdBordRec 
AND Baixat.cdRecebimento = BaixaR.cdRecebimento
WHERE Tit.dtPag BETWEEN '01/09/2019' AND '23/09/2019'
AND BaixaR.fDevolucao != 'S'
AND Tit.cdFilial = 0;

select 1 
from BaixaRec join BaixaRecTit on BaixaRecTit.cdBordRec = BaixaRec.cdBordRec and BaixaRecTit.cdRecebimento = BaixaRec.cdRecebimento 
where BaixaRecTit.Status = 'N' and BaixaRec.fDevolucao = 'S' and BaixaRecTit.dt = 5308;
