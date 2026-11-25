// servidor simples pra testar o IBGE_DESEMPREGO pela web
// na faculdade: npm install oracledb, ajuste a conexao e rode node server.js
// (nao precisa do Oracle Client instalado, o driver roda em modo thin)

const http = require('http');
const fs = require('fs');
const path = require('path');
const oracledb = require('oracledb');

// >>> AJUSTE AQUI PRA FACULDADE <<<
const DB_CONNECT = 'localhost:1539/FREEPDB1'; // host:porta/servico do oracle de la

// senhas dos perfis, iguais as do Privilegios_IBGE.sql
const PERFIS = {
    dono:       { user: 'IBGE_DESEMPREGO', password: 'senha123' },
    mapa_app:   { user: 'mapa_app',        password: 'mapa123' },
    site_admin: { user: 'site_admin',      password: 'admin123' }
};

// objetos que a tela pode listar, sempre pelo schema do dono
const OBJETOS = [
    'PAIS', 'REGIOES', 'ANALISTAS', 'ESTADOS', 'MUNICIPIOS', 'AUDITORIA',
    'INDICADORES_SOCIAIS', 'HISTORICO_DESEMPREGO',
    'VW_DESEMPREGO_MUNICIPIO', 'VW_DESEMPREGO_ESTADO', 'VW_RANKING_DESEMPREGO'
];
const DONO = 'IBGE_DESEMPREGO';

function json(res, obj) {
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(obj));
}

function lerCorpo(req) {
    return new Promise((ok, falhou) => {
        let t = '';
        req.on('data', c => t += c);
        req.on('end', () => { try { ok(JSON.parse(t || '{}')); } catch (e) { falhou(e); } });
    });
}

// abre a conexao LOGANDO COM O PERFIL ESCOLHIDO,
// assim quem aplica as permissoes e o proprio oracle
async function abrir(perfil) {
    return oracledb.getConnection({
        user: PERFIS[perfil].user,
        password: PERFIS[perfil].password,
        connectString: DB_CONNECT
    });
}

// ===== MAPA: consulta sempre com o perfil mapa_app (so SELECT nas views) =====
async function mapaConsulta(res, sql, binds = {}, unico = false) {
    let conn;
    try {
        conn = await abrir('mapa_app');
        const r = await conn.execute(sql, binds, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        const linhas = r.rows.map(l => Object.fromEntries(Object.entries(l).map(([k, v]) => [k.toLowerCase(), v])));
        if (unico) return linhas[0] ? json(res, linhas[0]) : (res.writeHead(404), res.end('{"erro":"municipio nao encontrado"}'));
        json(res, linhas);
    } catch (e) {
        res.writeHead(500, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify({ erro: String(e.message).split('\n')[0] }));
    } finally {
        if (conn) await conn.close().catch(() => {});
    }
}

const server = http.createServer(async (req, res) => {

    // pagina
    if (req.method === 'GET' && (req.url === '/' || req.url.startsWith('/index'))) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(fs.readFileSync(path.join(__dirname, 'index.html')));
        return;
    }

    // teste de conexao do perfil (mostra o usuario no topo da pagina)
    if (req.method === 'POST' && req.url === '/api/testar') {
        const { perfil } = await lerCorpo(req);
        if (!PERFIS[perfil]) return json(res, { erro: 'perfil invalido' });
        let conn;
        try {
            conn = await abrir(perfil);
            const r = await conn.execute('SELECT USER FROM DUAL');
            json(res, { usuario: r.rows[0][0] });
        } catch (e) {
            json(res, { erro: String(e.message).split('\n')[0] });
        } finally {
            if (conn) await conn.close().catch(() => {});
        }
        return;
    }

    // listar uma tabela ou view
    if (req.method === 'POST' && req.url === '/api/listar') {
        const { perfil, objeto } = await lerCorpo(req);
        if (!PERFIS[perfil]) return json(res, { erro: 'perfil invalido' });
        const alvo = String(objeto || '').toUpperCase();
        if (!OBJETOS.includes(alvo)) return json(res, { erro: 'objeto invalido' });
        let conn;
        try {
            conn = await abrir(perfil);
            // se o perfil nao tiver permissao, o ORACLE devolve o erro aqui
            const r = await conn.execute('SELECT * FROM ' + DONO + '.' + alvo + ' FETCH FIRST 200 ROWS ONLY');
            json(res, {
                usuario: PERFIS[perfil].user,
                colunas: r.metaData.map(c => c.name),
                linhas: r.rows
            });
        } catch (e) {
            json(res, { erro: String(e.message).split('\n')[0], codigo: e.errorNum });
        } finally {
            if (conn) await conn.close().catch(() => {});
        }
        return;
    }

    // chamar a procedure corrigir_municipio
    if (req.method === 'POST' && req.url === '/api/corrigir') {
        const { perfil, ibge, campo, valor, analista } = await lerCorpo(req);
        if (perfil !== 'site_admin') {
            return json(res, { erro: 'so o site_admin pode corrigir (veja o Privilegios_IBGE.sql)' });
        }
        let conn;
        try {
            conn = await abrir(perfil);
            await conn.execute(
                'BEGIN ' + DONO + '.CORRIGIR_MUNICIPIO(:ibge, :campo, :valor, :analista); END;',
                { ibge: Number(ibge), campo: String(campo), valor: Number(valor), analista: String(analista || 'site_admin') }
            );
            json(res, { ok: true });
        } catch (e) {
            json(res, { erro: String(e.message).split('\n')[0], codigo: e.errorNum });
        } finally {
            if (conn) await conn.close().catch(() => {});
        }
        return;
    }

    // ===== MAPA =====
    if (req.method === 'GET' && req.url === '/mapa') {
        // a chave do Google fica em variavel de ambiente, nao no codigo: GOOGLE_MAPS_KEY=... node server.js
        const html = fs.readFileSync(path.join(__dirname, 'mapa.html'), 'utf8')
            .replace('__GOOGLE_MAPS_KEY__', process.env.GOOGLE_MAPS_KEY || '');
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(html);
        return;
    }

    let m;
    if (req.method === 'GET' && req.url === '/api/mapa/estados') {
        return mapaConsulta(res,
            'SELECT sigla, nome, regiao, populacao, taxa_media, renda_media, qtd_municipios FROM ' + DONO + '.vw_desemprego_estado');
    }
    if (req.method === 'GET' && (m = req.url.match(/^\/api\/mapa\/uf\/([A-Za-z]{2})$/))) {
        return mapaConsulta(res,
            'SELECT codigo_ibge, nome, taxa_desemprego, renda_media, populacao FROM ' + DONO + '.vw_desemprego_municipio WHERE uf = :uf',
            { uf: m[1].toUpperCase() });
    }
    if (req.method === 'GET' && (m = req.url.match(/^\/api\/mapa\/municipio\/(\d{7})$/))) {
        return mapaConsulta(res,
            'SELECT * FROM (SELECT codigo_ibge, nome, uf, regiao, populacao, renda_media, taxa_desemprego, ' +
            'RANK() OVER (PARTITION BY uf ORDER BY taxa_desemprego DESC) AS posicao_uf, ' +
            'COUNT(*) OVER (PARTITION BY uf) AS total_uf, ' +
            'ROUND(AVG(taxa_desemprego) OVER (PARTITION BY uf), 2) AS media_uf, ' +
            'ROUND(AVG(taxa_desemprego) OVER (), 2) AS media_br ' +
            'FROM ' + DONO + '.vw_desemprego_municipio) WHERE codigo_ibge = :ibge',
            { ibge: Number(m[1]) }, true);
    }

    res.writeHead(404);
    res.end('nao encontrado');
});

server.listen(3000, () => console.log('painel no ar: http://localhost:3000'));
