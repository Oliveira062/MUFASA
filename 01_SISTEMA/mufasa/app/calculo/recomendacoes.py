"""
Motor de recomendacoes (SRS v1.1, Anexo F, G.1 e G.2).

Catalogo deterministico, mantido pela instituicao: nada aqui e gerado por
IA. Regras do motor (G.2):
- no maximo 4 recomendacoes por aluno por ciclo, ordenadas por severidade;
- recomendacao que depende de elegibilidade externa usa linguagem
  condicional ("verificar elegibilidade"), nunca "conceder";
- toda recomendacao mostra o fator que a originou;
- aluno menor de 18 anos passa pelo filtro de RN16.
"""

from app.calculo.score import ROTULOS

MAXIMO_POR_CICLO = 4

# Severidade: sobreposicoes primeiro (fato consumado), depois a pontuacao do fator.
_SEVERIDADE_SOBREPOSICAO = {"S2": 300, "S4": 290, "S3": 280, "S1": 270}


def _rec(codigo, texto, fator, perfil, severidade):
    return {"codigo": codigo, "texto": texto, "fator": fator, "perfil_atendimento": perfil,
            "severidade": round(severidade, 1)}


def gerar_recomendacoes(resultado: dict, dados: dict, menor_de_idade: bool = False) -> list[dict]:
    pontos = resultado.get("detalhamento", {})
    motivos = resultado.get("motivo_sobreposicao") or ""
    recs = []

    for codigo, texto, perfil in (
        ("S2", "Contato imediato por todos os canais cadastrados, conforme o protocolo de emergência (RN19).",
         "Pessoal e Emocional"),
        ("S4", "Entrevista de permanência antes do deferimento do trancamento.", "Pessoal"),
        ("S1", "Busca ativa formal; verificar a causa e eventual justificativa legal da ausência.", "Acadêmico"),
    ):
        if f"{codigo}:" in motivos:
            recs.append(_rec(codigo, texto, "frequencia" if codigo == "S1" else "sobreposicao", perfil,
                             _SEVERIDADE_SOBREPOSICAO[codigo]))

    # I1 por disciplina: pontuacao >= 50 na nota da disciplina.
    disciplinas_em_risco = [d.get("nome") for d in dados.get("disciplinas") or [] if d.get("i1") is not None
                            and d["i1"] >= 50]
    if len(disciplinas_em_risco) >= 3:
        recs.append(_rec("I1_TRES", "Plano de estudos individualizado; avaliar redução de carga "
                         f"({len(disciplinas_em_risco)} disciplinas com desempenho em risco).", "notas", "Acadêmico",
                         pontos.get("notas", 0)))
    elif disciplinas_em_risco:
        recs.append(_rec("I1_UMA", "Monitoria ou tutoria de pares em " + ", ".join(disciplinas_em_risco) + ".",
                         "notas", "Acadêmico", pontos.get("notas", 0)))

    i2 = pontos.get("frequencia")
    if i2 is not None and 40 <= i2 <= 79:
        recs.append(_rec("I2", "Contato do docente informando a frequência projetada e as faltas restantes.",
                         "frequencia", "Acadêmico", i2))
    if dados.get("reprovou_pre_requisito"):
        recs.append(_rec("I3_PRE", "Revisão do plano de integralização; oferta em período especial.", "reprovacao",
                         "Acadêmico", pontos.get("reprovacao", 0)))
    if dados.get("terceira_tentativa"):
        recs.append(_rec("I3_TERCEIRA", "Atendimento pedagógico individual; avaliar reorientação de percurso.",
                         "reprovacao", "Acadêmico", pontos.get("reprovacao", 0)))
    dias_ava = dados.get("dias_sem_acesso_ava")
    if dias_ava is not None and dias_ava > 21:
        recs.append(_rec("I4", "Verificar acesso à internet e a equipamento antes de supor desinteresse.",
                         "engajamento_ava", "Pessoal", pontos.get("engajamento_ava", 0)))
    i5 = pontos.get("financeiro")
    if i5 is not None and i5 >= 60 and not dados.get("auxilio_ativo"):
        recs.append(_rec("I5", "Encaminhar para verificação de elegibilidade a auxílio de permanência, transporte e "
                         "alimentação.", "financeiro", "Financeiro", i5))
    if (dados.get("mensalidades_atraso") or 0) > 0:
        texto = "Orientação sobre renegociação e crédito estudantil."
        if menor_de_idade:
            texto = "Orientação sobre renegociação, feita com o responsável legal (RN16)."
        recs.append(_rec("I5_ATRASO", texto, "financeiro", "Financeiro", i5 or 0))
    i6 = pontos.get("trabalho")
    if (i6 is not None and i6 >= 75) or dados.get("trabalho_mesmo_turno"):
        recs.append(_rec("I6", "Orientação sobre carga reduzida ou turno compatível.", "trabalho", "Pessoal", i6 or 0))
    i7 = pontos.get("deslocamento")
    if i7 is not None and i7 >= 75:
        recs.append(_rec("I7", "Verificar elegibilidade a auxílio-transporte; avaliar disciplinas híbridas, se houver.",
                         "deslocamento", "Financeiro", i7))
    i8 = pontos.get("saude_mental")
    if i8 is not None and i8 >= 70:
        texto = "Oferta de atendimento psicológico institucional ou encaminhamento à rede pública."
        if menor_de_idade:
            texto = ("Oferta de atendimento psicológico institucional ou encaminhamento à rede de proteção à criança "
                     "e ao adolescente, com o responsável legal (RN16).")
        recs.append(_rec("I8", texto, "saude_mental", "Emocional", i8))
    i10 = pontos.get("moradia")
    if i10 is not None and i10 >= 60:
        recs.append(_rec("I10", "Verificar elegibilidade a auxílio-moradia.", "moradia", "Financeiro", i10))
    i11 = pontos.get("dependentes")
    if i11 is not None and i11 >= 70:
        recs.append(_rec("I11", "Verificar elegibilidade a auxílio-creche; avaliar horários compatíveis.",
                         "dependentes", "Pessoal", i11))

    recs.sort(key=lambda r: -r["severidade"])
    for rec in recs:
        rec["fator_rotulo"] = ROTULOS.get(rec["fator"], "regra de sobreposição")
    return recs[:MAXIMO_POR_CICLO]
