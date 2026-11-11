# Painel web de teste do IBGE_DESEMPREGO

Painel pra demonstrar o banco na faculdade, sem precisar do Oracle na maquina:
ele conecta no Oracle do servidor da faculdade pela rede.

Sao dois arquivos: `server.js` (servidorzinho Node) e `index.html` (a tela).

## O que ele faz

- **Visualizar tabelas e views**: botao pra cada tabela e view. A conexao e aberta
  com o usuario do perfil escolhido (dono / mapa_app / site_admin), entao as
  permissoes do `Privilegios_IBGE.sql` valem de verdade — o mapa_app clicando
  em Municipios toma ORA-00942 na tela, que e exatamente a demonstracao do grant.
- **Testar a procedure**: formulario chama `corrigir_municipio` com codigo IBGE,
  campo, valor novo e analista. O update e o registro na `Correcoes` entram juntos.

## Pra rodar na faculdade

1. Ter o Node.js na maquina do lab (nodejs.org, instalacao rapida).
2. Dentro da pasta `web`, instalar o driver (uma vez):

   ```
   npm install oracledb
   ```

3. Abrir o `server.js` e ajustar no topo:
   - `DB_CONNECT`: host:porta/servico do Oracle da faculdade
     (ex.: `10.0.0.5:1521/XEPDB1` — pergunte o servico pro professor)
   - senha do perfil `dono`
4. Rodar:

   ```
   node server.js
   ```

5. Abrir `http://localhost:3000` no navegador.

Nao precisa do Oracle Client na maquina — o driver oracledb roda em modo thin.

## Senhas dos perfis

Iguais as do `Privilegios_IBGE.sql`: `mapa_app` = mapa123, `site_admin` = admin123.
Na faculdade, rode o `Privilegios_IBGE.sql` e o `Procedimentos_IBGE.sql` no banco
de la antes de usar o painel.
