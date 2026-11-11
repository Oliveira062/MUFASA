"""
Gestao / direcao: painel institucional (o painel de Gestao do app.py do F1,
agora ligado a API). So agregados: nenhum nome nem matricula, e grupo com
menos de 5 alunos suprimido no servidor (RN07, CA19).
"""

import streamlit as st

import cliente
import ui
from paginas import paineis


def hub():
    ui.cabecalho("Painel institucional", "Visão agregada de todos os cursos, atualizada automaticamente", "Gestão")
    ui.aviso("Visão agregada", "A gestão não vê nomes nem matrículas. Grupos com menos de 5 alunos são suprimidos "
             "(RN07, CA19).", "lock")
    curso = None
    with ui.secao():
        an = cliente.get("/api/v1/paineis/analises")
        cursos = [c["grupo"] for c in an["comparacao"]]
        if len(cursos) > 1:
            st.caption("Os filtros por curso usam o código do curso.")
    paineis.painel("DIRECAO", curso)


def relatorios():
    ui.cabecalho("Relatórios", "Exportação agregada, com rodapé de versão e confidencialidade (RF21, RN23)", "Gestão")
    with ui.secao("Distribuição institucional por nível"):
        visao = cliente.get("/api/v1/paineis/visao-geral")
        linhas = [{"nivel": ui.NOME_NIVEL.get(d["nivel"]), "alunos": "suprimido" if d["total"] is None else str(d["total"]),
                   "percentual": "" if d["pct"] is None else str(d["pct"])} for d in visao["distribuicao"]]
        com_pct = any(d.get("pct") is not None for d in visao["distribuicao"])
        ui.grade([("Nível", "e"), ("Alunos", "d")] + ([("Percentual", "d")] if com_pct else []),
                 [[ui.selo(d["nivel"]), ui.txt("suprimido" if d["total"] is None else d["total"])]
                  + ([ui.txt(None if d.get("pct") is None else f'{ui.numero_br(d["pct"])}%')] if com_pct else [])
                  for d in visao["distribuicao"]],
                 "Grupos com menos de 5 alunos aparecem como suprimido (LGPD).", "Distribuição institucional por nível")
        ui.botao_exportar(linhas, ["nivel", "alunos", "percentual"], "Distribuição institucional por nível",
                          "mufasa_distribuicao.csv")
    with ui.secao("Comparação entre cursos", "Grupos com menos de 5 alunos aparecem suprimidos"):
        an = cliente.get("/api/v1/paineis/analises")
        linhas = [{"curso": c["grupo"], **{ui.NOME_NIVEL[n]: ("suprimido" if v is None else str(v))
                                          for n, v in c["niveis"].items()}} for c in an["comparacao"]]
        if linhas:
            ui.grade_simples([{"Curso": l["curso"], **{k: v for k, v in l.items() if k != "curso"}} for l in linhas],
                             "Comparação entre cursos", direita=tuple(ui.NOME_NIVEL.values()))
            ui.botao_exportar(linhas, list(linhas[0].keys()), "Comparação entre cursos", "mufasa_cursos.csv")
