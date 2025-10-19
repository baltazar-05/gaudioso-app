# Gaudioso App

Aplicativo Flutter para gestão de reciclagem (materiais, parceiros, entradas/saídas, estoque e relatórios), com autenticação e integração a backend REST.

## Requisitos
- Flutter 3.35.6 (canal stable)
- Android toolchain configurado (SDK + licenças aceitas)
- Opcional: Visual Studio (para build Windows)

## Configuração de API
A base da API é configurável via `--dart-define`:
- Arquivo: `lib/core/api_config.dart`
 - Padrão: `https://api.gaudiosoreciclagens.com.br` (domínio fixo via Cloudflare Tunnel)
- Exemplo para apontar um backend remoto:
  - `flutter run --dart-define=API_BASE=https://seu-backend.com`

## Como rodar
- Instale dependências: `flutter pub get`
- Execute no dispositivo/emulador: `flutter run`
- Para web: `flutter run -d chrome`

## Notas da versão 1.2
- Nova tela de login com fluxo de registro e sessão persistida (`lib/screens/login/login_screen.dart`, `lib/services/auth_service.dart`).
- Integração com backend REST centralizada (`lib/services/api_service.dart` e `lib/core/api_config.dart`).
- Serviços atualizados para operações de CRUD e consumo de API:
  - Clientes, Fornecedores, Materiais, Entradas, Saídas, Estoque, Relatórios (pasta `lib/services/`).
- Menu e navegação aprimorados com opção de logout (`lib/screens/menu_screen.dart`).
- Novas dependências e melhorias de UI/UX:
  - `http`, `intl`, `provider`, `flutter_localizations`, `mask_text_input_formatter`, `google_fonts`, `sliding_up_panel`, `shared_preferences`.
- Diversas correções e ajustes de estabilidade.

## Notas da versão 1.1
- Fluxo de autenticação com tela de login e registro, integração com API e armazenamento local da sessão.
- Menu principal redesenhado com atalhos para materiais, parceiros, estoque, entradas, saídas e relatórios.
- CRUD completos para materiais, fornecedores e clientes, com validações de CPF/CNPJ e telefone.
- Telas de formulário e listagem para entradas e saídas de materiais totalmente conectadas ao backend.
- Consultas de estoque e relatórios com filtro por período e exibição de totais de entrada, saída e saldo.
- Camada de serviços HTTP centralizada (`ApiService`) e modelos tipados para todas as entidades.
- Utilitários para formatação dinâmica de CPF/CNPJ e validações reutilizáveis de campos.
- Dependências: http, intl, provider, flutter_localizations, mask_text_input_formatter, google_fonts, sliding_up_panel, shared_preferences.

## Cloudflare Tunnel (domínio fixo)

Permite expor seu backend local em um subdomínio público. Exemplo com o túnel `gaudioso-api` e o host `api.gaudiosoreciclagens.com.br`.

- Pré‑requisitos: conta Cloudflare e `cloudflared` instalado.
- Criar e apontar DNS:
  - `cloudflared tunnel login`
  - `cloudflared tunnel create gaudioso-api`
  - `cloudflared tunnel route dns gaudioso-api api.gaudiosoreciclagens.com.br`
- Configuração local (Windows): crie `C:\\Users\\vitor\\.cloudflared\\config.yml` com:

```
tunnel: a6cd0133-a03a-4c2a-a5c0-da02e5794c7e
credentials-file: C:\\Users\\vitor\\.cloudflared\\a6cd0133-a03a-4c2a-a5c0-da02e5794c7e.json

ingress:
  - hostname: api.gaudiosoreciclagens.com.br
    service: http://localhost:8080
  - service: http_status:404
```

- Executar o túnel: `cloudflared tunnel run gaudioso-api`
- Verificar: `cloudflared tunnel info gaudioso-api` e `cloudflared tunnel list`

Observação: ajuste `service:` para a porta/host do seu backend, se necessário (ex.: `http://127.0.0.1:8081`).

## Build de release (Android)
- Atualize a versão em `pubspec.yaml` (já em `1.2.0+2`).
- Gere APK: `flutter build apk --release`
- Ou AppBundle: `flutter build appbundle --release`

---

Para dúvidas ou problemas, abra uma issue no repositório.
