import os
import math
from PIL import Image, ImageDraw, ImageFont

def get_font(name="segoeui.ttf", size=14):
    try:
        return ImageFont.truetype(f"C:/Windows/Fonts/{name}", size)
    except:
        try:
            return ImageFont.truetype(f"C:/Windows/Fonts/arial.ttf", size)
        except:
            return ImageFont.load_default()

def draw_rounded_rect(draw, bbox, radius, fill, outline=None, width=1):
    x0, y0, x1, y1 = bbox
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill, outline=outline, width=width)

def draw_diamond(draw, cx, cy, w, h, fill, outline, width=2):
    pts = [
        (cx, cy - h//2),
        (cx + w//2, cy),
        (cx, cy + h//2),
        (cx - w//2, cy)
    ]
    draw.polygon(pts, fill=fill, outline=outline)
    if width > 1:
        for i in range(len(pts)):
            draw.line([pts[i], pts[(i+1)%len(pts)]], fill=outline, width=width)

# ==========================================
# 1. MODELO ENTIDADE-RELACIONAMENTO (MER)
# ==========================================
def generate_mer():
    W, H = 2600, 1850
    img = Image.new("RGB", (W, H), "#F8FAFC")
    draw = ImageDraw.Draw(img)

    f_title = get_font("segoeuib.ttf", 36)
    f_sub = get_font("segoeui.ttf", 20)
    f_ent_title = get_font("segoeuib.ttf", 20)
    f_ent_attr = get_font("segoeui.ttf", 15)
    f_rel = get_font("segoeuib.ttf", 15)
    f_badge = get_font("segoeuib.ttf", 15)
    f_card = get_font("segoeuib.ttf", 16)
    f_leg = get_font("segoeui.ttf", 16)
    f_leg_b = get_font("segoeuib.ttf", 16)

    # Header
    draw_rounded_rect(draw, (50, 40, W - 50, 130), 12, fill="#1E293B")
    draw.text((80, 55), "MODELO ENTIDADE-RELACIONAMENTO (MER) — HIERARQUIA TERRITORIAL CONCEITUAL", font=f_title, fill="#FFFFFF")
    draw.text((80, 98), "Hierarquia: PAIS (1) ──> REGIOES (N) ──> ESTADOS (N) ──> MUNICIPIOS (N) | Cardinalidades (1:1, 1:N) e (min, max)", font=f_sub, fill="#94A3B8")

    # Entities Data
    entities = {
        "PAIS": {
            "title": "PAIS",
            "attrs": ["(PK) id_pais", "nome", "populacao", "renda_media", "taxa_desemprego"],
            "rect": (80, 200, 360, 400),
            "header_color": "#1E40AF"
        },
        "REGIOES": {
            "title": "REGIOES",
            "attrs": ["(PK) id_regiao", "nome", "sigla", "area_km2", "qtd_estados"],
            "rect": (80, 560, 360, 770),
            "header_color": "#1E40AF"
        },
        "ESTADOS": {
            "title": "ESTADOS",
            "attrs": ["(PK) id_estado", "nome", "sigla", "regiao", "populacao", "renda_media", "taxa_desemprego"],
            "rect": (660, 450, 980, 720),
            "header_color": "#2563EB"
        },
        "INDICADORES_SOCIAIS": {
            "title": "INDICADORES_SOCIAIS",
            "attrs": ["(PK) id_indicador", "idhm", "pct_pobreza", "indice_gini"],
            "rect": (480, 960, 800, 1170),
            "header_color": "#7C3AED"
        },
        "HISTORICO_DESEMPREGO": {
            "title": "HISTORICO_DESEMPREGO",
            "attrs": ["(PK) id_historico", "ano", "taxa_desemprego", "renda_media"],
            "rect": (860, 960, 1180, 1170),
            "header_color": "#7C3AED"
        },
        "MUNICIPIOS": {
            "title": "MUNICIPIOS",
            "attrs": ["(PK) id_municipio", "nome", "uf", "codigo_ibge (UQ)", "populacao", "renda_media", "taxa_desemprego"],
            "rect": (1380, 450, 1720, 720),
            "header_color": "#0284C7"
        },
        "AUDITORIA": {
            "title": "AUDITORIA",
            "attrs": ["(PK) id_auditoria", "campo", "valor_antigo", "valor_novo", "analista", "data_correcao"],
            "rect": (1950, 650, 2300, 910),
            "header_color": "#059669"
        },
        "ANALISTAS": {
            "title": "ANALISTAS",
            "attrs": ["(PK) id_analista", "nome", "email (UQ)", "cargo", "departamento", "ativo"],
            "rect": (1950, 240, 2300, 480),
            "header_color": "#0D9488"
        }
    }

    # Relationships reflecting PAIS -> REGIOES -> ESTADOS -> MUNICIPIOS
    relations = [
        {"name": "ABRIGA", "macro": "1:N", "pos": (220, 480), "e1": "PAIS", "m1": "1", "c1": "(1,1)", "e2": "REGIOES", "m2": "N", "c2": "(1,n)"},
        {"name": "AGRUPA", "macro": "1:N", "pos": (510, 630), "e1": "REGIOES", "m1": "1", "c1": "(1,1)", "e2": "ESTADOS", "m2": "N", "c2": "(1,n)"},
        {"name": "POSSUI", "macro": "1:1", "pos": (670, 835), "e1": "ESTADOS", "m1": "1", "c1": "(1,1)", "e2": "INDICADORES_SOCIAIS", "m2": "1", "c2": "(1,1)"},
        {"name": "REGISTRA", "macro": "1:N", "pos": (920, 835), "e1": "ESTADOS", "m1": "1", "c1": "(1,1)", "e2": "HISTORICO_DESEMPREGO", "m2": "N", "c2": "(1,n)"},
        {"name": "CONTÉM", "macro": "1:N", "pos": (1180, 585), "e1": "ESTADOS", "m1": "1", "c1": "(1,1)", "e2": "MUNICIPIOS", "m2": "N", "c2": "(1,n)"},
        {"name": "AUDITADO_EM", "macro": "1:N", "pos": (1835, 600), "e1": "MUNICIPIOS", "m1": "1", "c1": "(1,1)", "e2": "AUDITORIA", "m2": "N", "c2": "(0,n)"},
        {"name": "EFETUA", "macro": "1:N", "pos": (2125, 560), "e1": "ANALISTAS", "m1": "1", "c1": "(1,1)", "e2": "AUDITORIA", "m2": "N", "c2": "(0,n)"}
    ]

    # Draw Relations & Connecting Lines
    for r in relations:
        cx, cy = r["pos"]
        e1 = entities[r["e1"]]["rect"]
        e2 = entities[r["e2"]]["rect"]
        c1_pt = ((e1[0] + e1[2])//2, (e1[1] + e1[3])//2)
        c2_pt = ((e2[0] + e2[2])//2, (e2[1] + e2[3])//2)

        # Connection lines
        draw.line([c1_pt, (cx, cy)], fill="#64748B", width=3)
        draw.line([(cx, cy), c2_pt], fill="#64748B", width=3)

        # Diamond
        rw, rh = 140, 64
        draw_diamond(draw, cx, cy, rw, rh, fill="#FFFFFF", outline="#0284C7", width=2)
        tw = draw.textlength(r["name"], font=f_rel)
        draw.text((cx - tw//2, cy - 9), r["name"], font=f_rel, fill="#0F172A")

        # Macro Badge (1:N ou 1:1)
        badge_text = f"  {r['macro']}  "
        bw = draw.textlength(badge_text, font=f_badge) + 12
        badge_bg = "#2563EB" if r["macro"] == "1:N" else "#7C3AED"
        draw_rounded_rect(draw, (cx - bw//2, cy - rh//2 - 26, cx + bw//2, cy - rh//2 - 2), 6, fill=badge_bg, outline="#1E293B", width=1)
        draw.text((cx - bw//2 + 6, cy - rh//2 - 24), badge_text, font=f_badge, fill="#FFFFFF")

        # Cardinalities Points
        m1x = (c1_pt[0] * 3 + cx) // 4
        m1y = (c1_pt[1] * 3 + cy) // 4
        m2x = (c2_pt[0] * 3 + cx) // 4
        m2y = (c2_pt[1] * 3 + cy) // 4

        draw_rounded_rect(draw, (m1x - 30, m1y - 15, m1x + 30, m1y + 15), 5, fill="#F1F5F9", outline="#94A3B8")
        draw.text((m1x - 24, m1y - 12), f"{r['m1']} {r['c1']}", font=f_card, fill="#0F172A")

        draw_rounded_rect(draw, (m2x - 30, m2y - 15, m2x + 30, m2y + 15), 5, fill="#F1F5F9", outline="#94A3B8")
        draw.text((m2x - 24, m2y - 12), f"{r['m2']} {r['c2']}", font=f_card, fill="#0F172A")

    # Draw Entities Boxes
    for k, e in entities.items():
        x0, y0, x1, y1 = e["rect"]
        draw_rounded_rect(draw, (x0+4, y0+4, x1+4, y1+4), 10, fill="#E2E8F0")
        draw_rounded_rect(draw, (x0, y0, x1, y1), 10, fill="#FFFFFF", outline="#CBD5E1", width=2)
        draw.rounded_rectangle([x0, y0, x1, y0 + 44], radius=10, fill=e["header_color"])
        draw.rectangle([x0, y0 + 30, x1, y0 + 44], fill=e["header_color"])

        tw = draw.textlength(e["title"], font=f_ent_title)
        draw.text(((x0 + x1)//2 - tw//2, y0 + 10), e["title"], font=f_ent_title, fill="#FFFFFF")

        cur_y = y0 + 56
        for attr in e["attrs"]:
            is_pk = "(PK)" in attr
            is_uq = "(UQ)" in attr
            color = "#0F172A"
            if is_pk:
                color = "#B45309"
            elif is_uq:
                color = "#4338CA"

            draw.ellipse((x0 + 16, cur_y + 6, x0 + 22, cur_y + 12), fill=color)
            draw.text((x0 + 32, cur_y), attr, font=f_ent_attr, fill=color)
            cur_y += 24

    # Legend & Notes at bottom
    leg_x0, leg_y0, leg_x1, leg_y1 = 80, 1550, W - 80, 1780
    draw_rounded_rect(draw, (leg_x0, leg_y0, leg_x1, leg_y1), 10, fill="#FFFFFF", outline="#CBD5E1", width=2)
    draw.text((leg_x0 + 30, leg_y0 + 20), "LEGENDA DE CARDINALIDADES E NOTAÇÕES:", font=get_font("segoeuib.ttf", 19), fill="#1E293B")

    draw_rounded_rect(draw, (leg_x0 + 30, leg_y0 + 60, leg_x0 + 85, leg_y0 + 88), 6, fill="#2563EB")
    draw.text((leg_x0 + 40, leg_y0 + 63), "1:N", font=f_badge, fill="#FFFFFF")
    draw.text((leg_x0 + 95, leg_y0 + 63), "Um para Muitos (ex: Pais -> Regioes, Regioes -> Estados, Estados -> Municipios)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 820, leg_y0 + 60, leg_x0 + 875, leg_y0 + 88), 6, fill="#7C3AED")
    draw.text((leg_x0 + 830, leg_y0 + 63), "1:1", font=f_badge, fill="#FFFFFF")
    draw.text((leg_x0 + 885, leg_y0 + 63), "Um para Um (exclusivo, cada estado possui 1 registro de indicadores)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 30, leg_y0 + 115, leg_x0 + 110, leg_y0 + 143), 5, fill="#F1F5F9", outline="#94A3B8")
    draw.text((leg_x0 + 36, leg_y0 + 118), "1 (1,1)", font=f_card, fill="#0F172A")
    draw.text((leg_x0 + 120, leg_y0 + 119), "Obrigatório unívoco (mínimo 1, máximo 1)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 570, leg_y0 + 115, leg_x0 + 650, leg_y0 + 143), 5, fill="#F1F5F9", outline="#94A3B8")
    draw.text((leg_x0 + 576, leg_y0 + 118), "N (1,n)", font=f_card, fill="#0F172A")
    draw.text((leg_x0 + 660, leg_y0 + 119), "Obrigatório múltiplo (mínimo 1, máximo n)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 1100, leg_y0 + 115, leg_x0 + 1180, leg_y0 + 143), 5, fill="#F1F5F9", outline="#94A3B8")
    draw.text((leg_x0 + 1106, leg_y0 + 118), "N (0,n)", font=f_card, fill="#0F172A")
    draw.text((leg_x0 + 1190, leg_y0 + 119), "Opcional múltiplo (mínimo 0, máximo n - auditoria)", font=f_leg, fill="#334155")

    draw.ellipse((leg_x0 + 30, leg_y0 + 175, leg_x0 + 42, leg_y0 + 187), fill="#B45309")
    draw.text((leg_x0 + 52, leg_y0 + 172), "(PK) Chave Primária", font=f_leg_b, fill="#B45309")

    draw.ellipse((leg_x0 + 260, leg_y0 + 175, leg_x0 + 272, leg_y0 + 187), fill="#4338CA")
    draw.text((leg_x0 + 282, leg_y0 + 172), "(UQ) Chave Alternativa Única", font=f_leg_b, fill="#4338CA")

    draw.text((leg_x0 + 650, leg_y0 + 172), "Esquema conceitual normalizado (3FN): Pais -> Regioes -> Estados -> Municipios", font=get_font("segoeuib.ttf", 16), fill="#059669")

    out_path = "modelagem/modelo_entidade_relacionamento.png"
    img.save(out_path, dpi=(300, 300))
    print(f"MER gerado em: {out_path}")

# ==========================================
# 2. MODELO RELACIONAL (DER / ESQUEMA LÓGICO)
# ==========================================
def generate_relacional():
    W, H = 2800, 1950
    img = Image.new("RGB", (W, H), "#F8FAFC")
    draw = ImageDraw.Draw(img)

    f_title = get_font("segoeuib.ttf", 36)
    f_sub = get_font("segoeui.ttf", 20)
    f_tbl_title = get_font("segoeuib.ttf", 19)
    f_col = get_font("segoeui.ttf", 14)
    f_col_b = get_font("segoeuib.ttf", 14)
    f_type = get_font("consola.ttf", 13)
    f_tag = get_font("segoeuib.ttf", 11)
    f_card_pill = get_font("segoeuib.ttf", 14)
    f_leg = get_font("segoeui.ttf", 16)

    # Header
    draw_rounded_rect(draw, (50, 40, W - 50, 130), 12, fill="#0F172A")
    draw.text((80, 55), "MODELO RELACIONAL — ESQUEMA LÓGICO / FÍSICO HIERÁRQUICO (3FN)", font=f_title, fill="#FFFFFF")
    draw.text((80, 98), "Hierarquia: Pais (PK) -> Regioes (FK id_pais) -> Estados (FK id_regiao) -> Municipios (FK id_estado)", font=f_sub, fill="#94A3B8")

    # Tables specification
    tables = {
        "Pais": {
            "title": "Pais",
            "cols": [
                ("id_pais", "NUMBER(4)", "PK"),
                ("nome", "VARCHAR2(50)", None),
                ("populacao", "NUMBER(12)", None),
                ("renda_media", "NUMBER(12,2)", None),
                ("taxa_desemprego", "NUMBER(5,2)", None),
            ],
            "rect": (80, 200, 440, 410),
            "color": "#1E40AF"
        },
        "Regioes": {
            "title": "Regioes",
            "cols": [
                ("id_regiao", "NUMBER(1)", "PK"),
                ("id_pais", "NUMBER(4)", "FK"),
                ("nome", "VARCHAR2(20)", "UQ"),
                ("sigla", "VARCHAR2(2)", "UQ"),
                ("area_km2", "NUMBER(10,2)", None),
                ("qtd_estados", "NUMBER(2)", None),
            ],
            "rect": (80, 520, 440, 760),
            "color": "#1E40AF"
        },
        "Estados": {
            "title": "Estados",
            "cols": [
                ("id_estado", "NUMBER(2)", "PK"),
                ("id_regiao", "NUMBER(1)", "FK"),
                ("nome", "VARCHAR2(50)", None),
                ("sigla", "VARCHAR2(2)", "UQ"),
                ("regiao", "VARCHAR2(20)", None),
                ("populacao", "NUMBER(12)", None),
                ("renda_media", "NUMBER(12,2)", None),
                ("taxa_desemprego", "NUMBER(5,2)", None),
            ],
            "rect": (660, 310, 1060, 650),
            "color": "#2563EB"
        },
        "Indicadores_Sociais": {
            "title": "Indicadores_Sociais",
            "cols": [
                ("id_indicador", "NUMBER(4)", "PK"),
                ("id_estado", "NUMBER(2)", "FK, UQ"),
                ("idhm", "NUMBER(4,3)", None),
                ("pct_pobreza", "NUMBER(5,2)", None),
                ("indice_gini", "NUMBER(4,3)", None),
            ],
            "rect": (480, 940, 880, 1160),
            "color": "#7C3AED"
        },
        "Historico_Desemprego": {
            "title": "Historico_Desemprego",
            "cols": [
                ("id_historico", "NUMBER(6)", "PK"),
                ("id_estado", "NUMBER(2)", "FK, UQ"),
                ("ano", "NUMBER(4)", "UQ"),
                ("taxa_desemprego", "NUMBER(5,2)", None),
                ("renda_media", "NUMBER(12,2)", None),
            ],
            "rect": (960, 940, 1370, 1160),
            "color": "#7C3AED"
        },
        "Municipios": {
            "title": "Municipios",
            "cols": [
                ("id_municipio", "NUMBER(6)", "PK"),
                ("id_estado", "NUMBER(2)", "FK"),
                ("uf", "VARCHAR2(2)", None),
                ("nome", "VARCHAR2(80)", None),
                ("codigo_ibge", "NUMBER(7)", "UQ"),
                ("populacao", "NUMBER(12)", None),
                ("renda_media", "NUMBER(12,2)", None),
                ("taxa_desemprego", "NUMBER(5,2)", None),
            ],
            "rect": (1480, 310, 1890, 660),
            "color": "#0284C7"
        },
        "Auditoria": {
            "title": "Auditoria",
            "cols": [
                ("id_auditoria", "NUMBER(8)", "PK"),
                ("codigo_ibge", "NUMBER(7)", "FK"),
                ("campo", "VARCHAR2(20)", None),
                ("valor_antigo", "NUMBER(12,2)", None),
                ("valor_novo", "NUMBER(12,2)", None),
                ("analista", "VARCHAR2(30)", None),
                ("id_analista", "NUMBER(4)", "FK"),
                ("data_correcao", "DATE", None),
            ],
            "rect": (2120, 640, 2560, 980),
            "color": "#059669"
        },
        "Analistas": {
            "title": "Analistas",
            "cols": [
                ("id_analista", "NUMBER(4)", "PK"),
                ("nome", "VARCHAR2(60)", None),
                ("email", "VARCHAR2(80)", "UQ"),
                ("cargo", "VARCHAR2(40)", None),
                ("departamento", "VARCHAR2(50)", None),
                ("ativo", "NUMBER(1)", None),
            ],
            "rect": (2120, 240, 2560, 510),
            "color": "#0D9488"
        }
    }

    # Foreign Key Connectors: PAIS -> REGIOES -> ESTADOS -> MUNICIPIOS
    fk_links = [
        # Regioes.id_pais -> Pais.id_pais
        {"from": (260, 520), "to": (260, 410), "color": "#1E40AF", "card": "1:N", "pk_label": "1", "fk_label": "N"},
        # Estados.id_regiao -> Regioes.id_regiao
        {"from": (660, 380), "to": (440, 590), "color": "#2563EB", "card": "1:N", "pk_label": "1", "fk_label": "N"},
        # Municipios.id_estado -> Estados.id_estado
        {"from": (1480, 380), "to": (1060, 350), "color": "#0284C7", "card": "1:N", "pk_label": "1", "fk_label": "N"},
        # Indicadores_Sociais.id_estado -> Estados.id_estado (1:1)
        {"from": (680, 940), "to": (750, 650), "color": "#7C3AED", "card": "1:1", "pk_label": "1", "fk_label": "1"},
        # Historico_Desemprego.id_estado -> Estados.id_estado (1:N)
        {"from": (1100, 940), "to": (950, 650), "color": "#7C3AED", "card": "1:N", "pk_label": "1", "fk_label": "N"},
        # Auditoria.codigo_ibge -> Municipios.codigo_ibge (1:N)
        {"from": (2120, 715), "to": (1890, 490), "color": "#059669", "card": "1:N", "pk_label": "1", "fk_label": "N"},
        # Auditoria.id_analista -> Analistas.id_analista (1:N)
        {"from": (2340, 640), "to": (2340, 510), "color": "#0D9488", "card": "1:N", "pk_label": "1", "fk_label": "N"}
    ]

    # Draw FK connection lines
    for l in fk_links:
        fx, fy = l["from"]
        tx, ty = l["to"]
        color = l["color"]

        # Orthogonal path
        mid_x = (fx + tx) // 2
        mid_y = (fy + ty) // 2

        if fx == tx:
            # Vertical straight line
            draw.line([(fx, fy), (tx, ty)], fill=color, width=3)
            badge_x, badge_y = fx, mid_y
        else:
            draw.line([(fx, fy), (mid_x, fy)], fill=color, width=3)
            draw.line([(mid_x, fy), (mid_x, ty)], fill=color, width=3)
            draw.line([(mid_x, ty), (tx, ty)], fill=color, width=3)
            badge_x, badge_y = mid_x, mid_y

        draw.ellipse((fx - 5, fy - 5, fx + 5, fy + 5), fill=color)

        if tx > mid_x and fx != tx:
            draw.polygon([(tx, ty), (tx - 10, ty - 6), (tx - 10, ty + 6)], fill=color)
        elif tx < mid_x and fx != tx:
            draw.polygon([(tx, ty), (tx + 10, ty - 6), (tx + 10, ty + 6)], fill=color)
        elif ty > fy:
            draw.polygon([(tx, ty), (tx - 6, ty - 10), (tx + 6, ty - 10)], fill=color)
        else:
            draw.polygon([(tx, ty), (tx - 6, ty + 10), (tx + 6, ty + 10)], fill=color)

        # Cardinality Badge directly on line
        b_text = f" {l['card']} "
        bw = draw.textlength(b_text, font=f_card_pill) + 10
        draw_rounded_rect(draw, (badge_x - bw//2, badge_y - 12, badge_x + bw//2, badge_y + 12), 5, fill="#FFFFFF", outline=color, width=2)
        draw.text((badge_x - bw//2 + 5, badge_y - 10), b_text, font=f_card_pill, fill=color)

        draw.text((tx + (10 if tx < fx else -20), ty - 18), l["pk_label"], font=get_font("segoeuib.ttf", 16), fill=color)
        draw.text((fx + (-22 if tx < fx else 10), fy - 18), l["fk_label"], font=get_font("segoeuib.ttf", 16), fill=color)

    # Draw Table Cards
    for k, t in tables.items():
        x0, y0, x1, y1 = t["rect"]
        draw_rounded_rect(draw, (x0+5, y0+5, x1+5, y1+5), 10, fill="#E2E8F0")
        draw_rounded_rect(draw, (x0, y0, x1, y1), 10, fill="#FFFFFF", outline="#CBD5E1", width=2)
        draw.rounded_rectangle([x0, y0, x1, y0 + 44], radius=10, fill=t["color"])
        draw.rectangle([x0, y0 + 30, x1, y0 + 44], fill=t["color"])

        draw.text((x0 + 16, y0 + 10), t["title"], font=f_tbl_title, fill="#FFFFFF")

        cur_y = y0 + 54
        for col_name, col_type, tag in t["cols"]:
            if tag:
                if "PK" in tag:
                    draw_rounded_rect(draw, (x0 + 14, cur_y + 1, x0 + 42, cur_y + 19), 4, fill="#FEF3C7", outline="#D97706")
                    draw.text((x0 + 18, cur_y + 3), "PK", font=f_tag, fill="#B45309")
                elif "FK" in tag:
                    draw_rounded_rect(draw, (x0 + 14, cur_y + 1, x0 + 42, cur_y + 19), 4, fill="#DBEAFE", outline="#2563EB")
                    draw.text((x0 + 19, cur_y + 3), "FK", font=f_tag, fill="#1D4ED8")

            f_to_use = f_col_b if tag and "PK" in tag else f_col
            color_to_use = "#0F172A" if not (tag and "PK" in tag) else "#B45309"
            draw.text((x0 + 52, cur_y + 2), col_name, font=f_to_use, fill=color_to_use)

            if tag and "UQ" in tag:
                draw_rounded_rect(draw, (x1 - 180, cur_y + 2, x1 - 150, cur_y + 18), 3, fill="#EDE9FE", outline="#7C3AED")
                draw.text((x1 - 176, cur_y + 3), "UQ", font=f_tag, fill="#6D28D9")

            tw = draw.textlength(col_type, font=f_type)
            draw.text((x1 - tw - 16, cur_y + 3), col_type, font=f_type, fill="#64748B")

            draw.line([(x0 + 10, cur_y + 26), (x1 - 10, cur_y + 26)], fill="#F1F5F9", width=1)
            cur_y += 30

    # Legend & Notes at bottom
    leg_x0, leg_y0, leg_x1, leg_y1 = 80, 1620, W - 80, 1860
    draw_rounded_rect(draw, (leg_x0, leg_y0, leg_x1, leg_y1), 10, fill="#FFFFFF", outline="#CBD5E1", width=2)
    draw.text((leg_x0 + 30, leg_y0 + 20), "LEGENDA DO ESQUEMA RELACIONAL E CARDINALIDADES:", font=get_font("segoeuib.ttf", 19), fill="#1E293B")

    draw_rounded_rect(draw, (leg_x0 + 30, leg_y0 + 60, leg_x0 + 85, leg_y0 + 88), 5, fill="#FFFFFF", outline="#2563EB", width=2)
    draw.text((leg_x0 + 40, leg_y0 + 64), " 1:N ", font=f_card_pill, fill="#2563EB")
    draw.text((leg_x0 + 95, leg_y0 + 64), "Relação 1 para N (Hierarquia 3FN: Pais -> Regioes -> Estados -> Municipios)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 840, leg_y0 + 60, leg_x0 + 895, leg_y0 + 88), 5, fill="#FFFFFF", outline="#7C3AED", width=2)
    draw.text((leg_x0 + 850, leg_y0 + 64), " 1:1 ", font=f_card_pill, fill="#7C3AED")
    draw.text((leg_x0 + 905, leg_y0 + 64), "Relação 1 para 1 (FK com constraint UNIQUE - relação unívoca)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 30, leg_y0 + 115, leg_x0 + 65, leg_y0 + 137), 4, fill="#FEF3C7", outline="#D97706")
    draw.text((leg_x0 + 38, leg_y0 + 118), "PK", font=f_tag, fill="#B45309")
    draw.text((leg_x0 + 75, leg_y0 + 116), "Primary Key (Chave Primária)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 380, leg_y0 + 115, leg_x0 + 415, leg_y0 + 137), 4, fill="#DBEAFE", outline="#2563EB")
    draw.text((leg_x0 + 388, leg_y0 + 118), "FK", font=f_tag, fill="#1D4ED8")
    draw.text((leg_x0 + 425, leg_y0 + 116), "Foreign Key (Chave Estrangeira)", font=f_leg, fill="#334155")

    draw_rounded_rect(draw, (leg_x0 + 750, leg_y0 + 115, leg_x0 + 785, leg_y0 + 137), 4, fill="#EDE9FE", outline="#7C3AED")
    draw.text((leg_x0 + 756, leg_y0 + 118), "UQ", font=f_tag, fill="#6D28D9")
    draw.text((leg_x0 + 795, leg_y0 + 116), "Unique Constraint (Restrição de Unicidade)", font=f_leg, fill="#334155")

    draw.line([(leg_x0 + 30, leg_y0 + 175), (leg_x0 + 70, leg_y0 + 175)], fill="#2563EB", width=3)
    draw.polygon([(leg_x0 + 75, leg_y0 + 175), (leg_x0 + 68, leg_y0 + 170), (leg_x0 + 68, leg_y0 + 180)], fill="#2563EB")
    draw.ellipse((leg_x0 + 26, leg_y0 + 171, leg_x0 + 34, leg_y0 + 179), fill="#2563EB")
    draw.text((leg_x0 + 85, leg_y0 + 168), "Linha de Integridade Referencial: Círculo (Lado N / FK) ───> Seta (Lado 1 / PK)", font=f_leg, fill="#334155")

    draw.text((leg_x0 + 800, leg_y0 + 168), "Oracle Database & MySQL — 8 tabelas integradas", font=get_font("segoeuib.ttf", 16), fill="#059669")

    out_path = "modelagem/modelo_relacional.png"
    img.save(out_path, dpi=(300, 300))
    print(f"Modelo Relacional gerado em: {out_path}")

if __name__ == "__main__":
    generate_mer()
    generate_relacional()
