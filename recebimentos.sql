EXEC dbo.spRelC123 0,'-1','-1','-1','-1','-1','-1','-1','-1','-1','-1','-1','-1','-1','-1','01-05-2019', '31/05/2019','S',
'-1','-1','-1', 'S';

select * from GRUPO;

select Tit.NrDoc, Tit.ped  
from vfTituloCRE AS Tit with(nolock) 
INNER JOIN vcEntcli AS Cli ON Tit.cdCliente = Cli.cdCliente
LEFT OUTER JOIN vfNotaCRE as NF with(nolock) ON Tit.NF = NF.cdNf;


select * from BordRec with(nolock);
select * from vcEntcli;
select * from vfTituloCRE with(nolock) where dtVencto BETWEEN '01/04/2019' and '30/07/2019';
select * from vfNotaCRE with(nolock);
select * from TpCobRec with(nolock);

select * from BordRec;
exec sp_executesql N'declare @exibirNFS char(1) set @exibirNFS = @P1 select convert(float, vfTituloCRE.cdRec) as cdRec, vfTituloCRE.Nrdoc, convert(dateTime, convert(char(11), vfTituloCRE.dtEmissao)) as dtEmissao,
convert(dateTime, convert(char(11), vfTituloCRE.dtDigi)) as dtDigi, vfTituloCRE.dtVencto, vfTituloCRE.vlBruto, case when @exibirNFS = ''S'' then isnull(vfNotaCRE.NfServico,convert(float, vfNotaCRE.Nf)) else convert(float, vfNotaCRE.Nf) end as notaFiscal,
convert(float, vfNotaCRE.Nf) as nf, convert(float, vfNotaCRE.cdNf) as cdNf, convert(float, vfTituloCRE.cdCliente) as cdCliente, vfNotaCRE.NfServico,
vcEntCli.nmEntCli as nmCliente, convert(float, IsNull(vfTituloCRE.cdRepres, IsNull(vfNotaCRE.cdRepres, vcEntCli.cdRepres))) as cdRepres, Repres.nmRepres,  dbo.fcTelefone_Format(vcentcli.fone1) as foneCliente, vcEntCli.RazaoSocial as rsCliente,
convert(float, vfTituloCRE.cdBordRec) as cdBordRec, '' '' dsCedente, TpCobrec.dsCobRec, Reembolso.Status as StatusReemb, vfTituloCRE.Status,
vfTituloCRE.cdEstagioCob, vfTituloCRE.tpDoc , DATEDIFF(day,vfTituloCRE.dtVencto,getdate()) as DiasAtraso, IsNull(vfTituloCRE.percDesconto, 0) as percDesconto
FROM  vfTituloCRE WITH (nolock) LEFT OUTER JOIN vfNotaCRE WITH (nolock) ON vfTituloCRE.cdNF = vfNotaCRE.cdNf INNER JOIN vcEntcli WITH (nolock) ON vfTituloCRE.cdCliente = vcEntcli.cdCliente
      LEFT OUTER JOIN Repres (nolock) on IsNull(vfTituloCRE.cdRepres, IsNull(vfNotaCRE.cdRepres, vcEntCli.cdRepres)) = Repres.cdRepres
      LEFT OUTER JOIN TpCobRec WITH (nolock) ON vfTituloCRE.cdCobRec = TpCobRec.cdCobRec LEFT OUTER JOIN Reembolso WITH (nolock) ON vfTituloCRE.cdRec = Reembolso.cdRec
WHERE (vfTituloCRE.cdBordRec IS NULL)
 and vfTituloCRE.cdfilial = 0 and vfTituloCRE.Status = ''N'' and vfTituloCRE.cdRec not in (select cdRec from Reembolso) and vfTituloCRE.dtVencto between ''09/01/19'' and ''12/31/19''
union
select convert(float, vfTituloCRE.cdRec) as cdRec, vfTituloCRE.Nrdoc, convert(dateTime, convert(char(11), vfTituloCRE.dtEmissao)) as dtEmissao,
convert(dateTime, convert(char(11), vfTituloCRE.dtDigi)) as dtDigi, vfTituloCRE.dtVencto, vfTituloCRE.vlBruto, case when @exibirNFS = ''S'' then isnull(vfNotaCRE.NfServico,convert(float, vfNotaCRE.Nf)) else convert(float, vfNotaCRE.Nf) end as notaFiscal,
convert(float, vfNotaCRE.Nf) as nf, convert(float, vfNotaCRE.cdNf) as cdNf, convert(float, vfTituloCRE.cdCliente) as cdCliente,  vfNotaCRE.NfServico,
vcEntCli.nmEntCli as nmCliente, convert(float, IsNull(vfTituloCRE.cdRepres, IsNull(vfNotaCRE.cdRepres, vcEntCli.cdRepres))) as cdRepres, Repres.nmRepres,  dbo.fcTelefone_Format(vcentcli.fone1) as foneCliente, vcEntCli.RazaoSocial as rsCliente,
convert(float, vfTituloCRE.cdBordRec) as cdBordRec, Cedente.dsCedente, TpCobrec.dsCobRec, Reembolso.Status as StatusReemb, vfTituloCRE.Status,
vfTituloCRE.cdEstagioCob, vfTituloCRE.tpDoc, DATEDIFF(day,vfTituloCRE.dtVencto,getdate()) as DiasAtraso, IsNull(vfTituloCRE.percDesconto, 0) as percDesconto
FROM vfTituloCRE WITH (nolock) LEFT OUTER JOIN vfNotaCRE WITH (nolock) ON vfTituloCRE.cdNF = vfNotaCRE.cdNf INNER JOIN vcEntcli WITH (nolock) ON vfTituloCRE.cdCliente = vcEntcli.cdCliente
     LEFT OUTER JOIN Repres (nolock) on IsNull(vfTituloCRE.cdRepres, IsNull(vfNotaCRE.cdRepres, vcEntCli.cdRepres)) = Repres.cdRepres
     INNER JOIN BordRec WITH (nolock) ON vfTituloCRE.cdBordRec = BordRec.cdBordRec INNER JOIN Cedente WITH (nolock) ON BordRec.cdCedente = Cedente.cdCedente LEFT OUTER JOIN
     TpCobRec WITH (nolock) ON vfTituloCRE.cdCobRec = TpCobRec.cdCobRec LEFT OUTER JOIN Reembolso WITH (nolock) ON vfTituloCRE.cdRec = Reembolso.cdRec
WHERE (vfTituloCRE.cdBordRec IS NOT NULL)
 and vfTituloCRE.cdfilial = 0 and vfTituloCRE.Status = ''N'' and vfTituloCRE.cdRec not in (select cdRec from Reembolso) and vfTituloCRE.dtVencto between ''09/01/19'' and ''12/31/19''
 order by nmCliente,
dtVencto
',N'@P1 varchar(1)','N'