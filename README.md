# StreamCut Studio — edição para streamers

**Projeto refeito do zero.** Aplicativo web de execução local com **cadastro real, login por sessão, SQLite, biblioteca por usuário, upload de vídeos, importação autorizada de links do YouTube, cortes verticais 9:16 com FFmpeg, IA opcional com OpenAI e publicação/agendamento com OAuth para TikTok, YouTube Shorts e X**.

> A interface não é uma simulação: a conta e os cortes são processados e armazenados no servidor. Publicações nas plataformas dependem de credenciais OAuth válidas, aprovações e requisitos de cada serviço. **Testado localmente:** criar conta, enviar vídeo de teste, gerar um MP4 real e verificar isolamento entre usuários. **Não foram testadas publicações reais em contas externas** porque não temos suas chaves/contas.

## Comece em 4 passos (computador Windows)

1. Instale **[Node.js 22.13 ou superior](https://nodejs.org/)** (preferencialmente LTS atual). No terminal do Windows, confirme `node -v`.
2. Instale **[FFmpeg e FFprobe](https://ffmpeg.org/download.html)**, com ambos disponíveis no `PATH`. No PowerShell, confirme `ffmpeg -version` e `ffprobe -version`. Pode usar `winget install Gyan.FFmpeg` se esse pacote estiver disponível no seu Windows.
3. Se quiser importar **links autorizados do YouTube**, instale Python 3 e, no terminal, rode `python -m pip install -U "yt-dlp[default]"`. Confira `python -m yt_dlp --version`.
4. Extraia este ZIP e **clique duas vezes em `INICIAR_WINDOWS.bat`**. O navegador abre em `http://localhost:3000`. Clique em **Criar minha conta**. **Deixe o terminal aberto** enquanto o app processa ou publica.

**Linux/macOS/Termux (Android):** com Node 22+, FFmpeg e Python/yt-dlp instalados, rode `bash iniciar.sh`. No Termux você pode precisar usar `pkg install nodejs ffmpeg python`, `python -m pip install "yt-dlp[default]"`, e `node server.js` (a versão de Node disponível precisa ser ≥22.13). O browser do **mesmo dispositivo** acessa `http://localhost:3000`.

**Sem precisar programar:** coloque as chaves em um arquivo `.env` na pasta do app, copiando o modelo `.env.example`, e abra com o script de iniciar. Se rodar `node server.js` diretamente, configure variáveis de ambiente manualmente porque o Node não lê `.env` sozinho.

## Fluxo de trabalho

1. Cadastre sua conta e entre.
2. Abra **Importar live**, arraste uma gravação original, ou cole um link de vídeo que você tem autorização para processar e marque a confirmação.
3. A opção **Gerar 3 cortes automaticamente** já vem marcada na importação. Se preferir, desmarque-a, abra **Minhas lives**, clique **Gerar cortes** e escolha 1 a 8 cortes de 15 a 90 segundos. A IA é **opcional**.
4. Em **Meus cortes**, assista, ajuste título/legenda e baixe em MP4 vertical.
5. Em **Redes conectadas**, conecte cada rede OAuth. Ao tocar **Publicar**, escolha rede, descrição, privacidade e horário. Em **Meus cortes**, use **Agendar em lote** para programar até 20 cortes espaçados. Posts de **X** são **somente texto** nesta versão; TikTok e Shorts enviam vídeo.
6. Acompanhe em **Publicações**. É o **servidor** que envia automaticamente nas datas escolhidas. Desligar o computador interrompe os agendamentos.

## Algoritmo automático e IA

- **Modo grátis:** analisa picos e variações de áudio para sugerir trechos e renderizá-los em 720×1280 com FFmpeg. É uma heurística, não entende a piada ou o contexto e **não promete selecionar os melhores cortes**.
- **Modo IA (opcional):** configure `OPENAI_API_KEY` no `.env`. O servidor extrai áudio, usa `whisper-1` para transcrição, envia a transcrição para `gpt-4o-mini` para sugerir momentos, produz legendas SRT e as insere nos MP4. Limite desta primeira versão: a IA analisa **até a primeira hora** de cada vídeo; a análise por áudio usa o arquivo completo. Há **custos de API** conforme sua utilização.
- O enquadramento atual é um **corte central** para 9:16, sem rastreamento de rosto/jogabilidade. Para perfis com webcam na lateral, o resultado talvez precise de ajustes manuais num editor externo.

## Chaves/APIs: quais precisa e como pegar

A importação de arquivo e os cortes por áudio **não precisam de API paga**. Apenas Node + FFmpeg são obrigatórios para esse modo. O download por link **não exige chave da API YouTube Data**, mas depende de `yt-dlp`, de conteúdos autorizados, e está sujeito a falhas e aos termos do YouTube. Não há promessa de que qualquer vídeo funcione.

### 1. OpenAI (opcional: transcrição e seleção inteligente)

- Acesse [platform.openai.com/api-keys](https://platform.openai.com/api-keys), crie uma chave e ative faturamento conforme aplicável.
- Cole no `.env`: `OPENAI_API_KEY=sk-...`
- Reinicie o aplicativo. Não envie a chave para outras pessoas nem a suba no GitHub.

### 2. TikTok (publicação de cortes)

- Acesse [developers.tiktok.com](https://developers.tiktok.com/), registre-se como desenvolvedor e crie um aplicativo.
- Adicione os produtos **Login Kit** e **Content Posting API**. Configure o **Direct Post** e solicite as permissões **`user.info.basic`** (conforme produto) e **`video.publish`**. Para publicação pública sem restrições, normalmente será necessária **auditoria do TikTok**.
- Registre no app a URL de callback **`http://localhost:3000/oauth/tiktok/callback`** *apenas caso o painel aceite essa URL para testes*. Em geral o TikTok pode exigir **domínio HTTPS público verificado**; nesse caso hospede a aplicação em um domínio HTTPS, ajuste `BASE_URL=https://seu-dominio` e registre `https://seu-dominio/oauth/tiktok/callback`.
- Copie **Client key** e **Client secret** para `TIKTOK_CLIENT_KEY` e `TIKTOK_CLIENT_SECRET`.
- Reinicie. Dentro do StreamCut Studio, vá a **Redes conectadas → Conectar TikTok**; autorize a conta. A publicação pede **consentimento explícito** e usa a privacidade permitida pela conta.
- [Documentação oficial Direct Post](https://developers.tiktok.com/docs/en/content-posting-api-get-started) | [Scopes](https://developers.tiktok.com/docs/en/tiktok-api-scopes) | [Creator info](https://developers.tiktok.com/docs/en/content-posting-api-reference-query-creator-info)

### 3. YouTube (envio de Shorts)

- Abra [console.cloud.google.com](https://console.cloud.google.com/), crie um projeto e habilite a **YouTube Data API v3**.
- Configure a **tela de consentimento OAuth** em Google Auth Platform, com usuários de teste enquanto o app estiver em teste.
- Crie uma credencial **OAuth Client ID**, tipo **Web application**. Adicione a URI autorizada `http://localhost:3000/oauth/youtube/callback` no ambiente local. Para domínio público, cadastre a versão HTTPS correspondente.
- Copie `Client ID` e `Client secret` para `GOOGLE_CLIENT_ID` e `GOOGLE_CLIENT_SECRET` no `.env`.
- Reinicie. No app, clique **Conectar YouTube** e aceite o escopo **`https://www.googleapis.com/auth/youtube.upload`**.
- O upload usa **`videos.insert`** e privacidade selecionada por você (privado, não listado ou público). Contas, apps e projetos não verificados podem ter restrições; cumpra a política da API e a verificação aplicável.
- [Guia oficial de upload](https://developers.google.com/youtube/data/guides/uploading_a_video) | [Credenciais OAuth](https://developers.google.com/identity/protocols/oauth2/web-server) | [Políticas YouTube](https://developers.google.com/youtube/terms/developer-policies/)

### 4. X / Twitter (posts de texto programados)

- Acesse [developer.x.com](https://developer.x.com/), crie projeto/aplicativo e habilite a API com permissão **Read and Write** e OAuth 2.0 de usuário.
- Configure o callback `http://localhost:3000/oauth/x/callback` no desenvolvimento, ou a versão HTTPS pública correspondente.
- Solicite os escopos `tweet.read`, `tweet.write`, `users.read`, `offline.access`.
- Copie **Client ID** e, se disponibilizado, **Client secret** para `X_CLIENT_ID` e `X_CLIENT_SECRET`. Alguns tipos de cliente usam PKCE com client ID apenas.
- Reinicie; no app, **Conectar X**. Publicação de **texto** usa `POST /2/tweets` (até 280 caracteres nesta versão). O envio de vídeo ao X ainda **não está implementado**.
- **A API do X usa modelo de cobrança por uso**, sujeito a mudanças; confirme no portal antes de publicar.
- [Documentação oficial do X API](https://developer.x.com/) | [Publicar posts](https://github.com/xdevplatform/docs/blob/main/x-api/posts/manage-tweets/introduction.mdx)

## Arquitetura e segurança

```text
streamcut_studio/
├─ server.js              API HTTP + autenticação + OAuth + fila + SQLite
├─ static/
│  ├─ index.html          interface responsiva
│  ├─ app.js              frontend e telas
│  ├─ style.css           estilos
│  └─ favicon.svg
├─ .env.example           modelo de credenciais
├─ .gitignore             evita subir tokens, vídeos e banco
├─ iniciar.sh
├─ iniciar.ps1
├─ INICIAR_WINDOWS.bat
└─ data/                  criado automaticamente, NÃO sobe ao GitHub
    ├─ streamcut.sqlite  contas/agenda/cortes
    ├─ .local-secret      segredo criptográfico
    ├─ videos/            originais baixados ou enviados
    └─ clips/             MP4 gerados
```

- Senhas: `scrypt` com salt individual; sessões aleatórias em cookie `HttpOnly`, `SameSite=Lax`; proteção CSRF nas operações autenticadas; banco SQLite separado por usuário.
- Tokens de redes: criptografia AES-256-GCM no servidor, baseada no segredo de instalação. Faça backup de **`data/` INTEIRA**, inclusive `.local-secret`, ou os tokens não poderão ser descriptografados.
- Importação: links limitados a YouTube para evitar usar o servidor para baixar conteúdo arbitrário; exige confirmação expressa de direito de uso.
- Sem dependências npm. Node ≥22.13, por causa do módulo nativo `node:sqlite` (experimental em algumas versões).
- **Não exponha a instância local à internet como está:** é um MVP para uso local. Antes de disponibilizar SaaS multiusuário precisa de HTTPS, ambiente seguro, limites de armazenamento e execução, backups, política de privacidade/LGPD, verificação das APIs, fila persistente (ex. Redis), varredura de arquivos e melhoria de rate limits/autenticação. Atualmente os workers são internos ao processo Node.
- O app **não tem** edição visual com arrastar e soltar, detecção de rostos, Twitch OAuth, Instagram, subida de vídeo no X, análise de métricas da plataforma ou garantia de seleção viral. São funcionalidades para evolução.

## GitHub: atualizando seu repositório

1. Extraia o ZIP.
2. No repositório do GitHub, faça upload dos arquivos e pastas extraídos, **mantendo `.gitignore`**. Não inclua o diretório `data`, o `.env` nem suas chaves.
3. Use `git add . && git commit -m "Refaz app para streamers com backend e cortes" && git push` se usa Git no PC.
4. GitHub Pages **não consegue rodar este backend**. Use no seu computador com `node server.js`, ou hospede em um serviço que mantenha Node e FFmpeg ativos, com armazenamento persistente.

## Diagnóstico rápido

- **Erro `FFmpeg` / `ffprobe`:** instale-os e reinicie o terminal.
- **Erro `yt-dlp` ou `No module named yt_dlp`:** `python -m pip install -U "yt-dlp[default]"`; faça apenas importações autorizadas.
- **Não aparece opção de conectar:** preencha as variáveis no `.env`, abra pelo script e reinicie.
- **Erro `redirect_uri_mismatch`:** o callback cadastrado precisa ser *idêntico* ao usado por `BASE_URL`.
- **Publicações não saem:** o servidor precisa ficar aberto; veja o status de erro na tela **Publicações**; sem liberação da API a plataforma pode rejeitar o envio.
- **Link funciona em outros sites, mas falha aqui:** alguns links exigem autenticação, podem estar geobloqueados ou as rotinas do download precisam ser atualizadas; nenhuma ferramenta garante 100% dos links.
