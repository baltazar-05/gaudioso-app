# Gaudioso App

Aplicativo Flutter para gest�o de reciclagem (materiais, parceiros, entradas/sa�das, estoque e relat�rios), com autentica��o e integra��o a backend REST.

## Requisitos
- Flutter 3.35.6 (canal stable)
- Android toolchain configurado (SDK + licen�as aceitas)
- Opcional: Visual Studio (para build Windows)

## Configura��o de API
A base da API � configur�vel via `--dart-define`:
- Arquivo: `lib/core/api_config.dart`
 - Padr�o: `https://api.gaudiosoreciclagens.com.br` (dom�nio fixo via Cloudflare Tunnel)
- Exemplo para apontar um backend remoto:
  - `flutter run --dart-define=API_BASE=https://seu-backend.com`

## Como rodar
- Instale depend�ncias: `flutter pub get`
- Execute no dispositivo/emulador: `flutter run`
- Para web: `flutter run -d chrome`

## Notas da vers�o 1.2
- Nova tela de login com fluxo de registro e sess�o persistida (`lib/screens/login/login_screen.dart`, `lib/services/auth_service.dart`).
- Integra��o com backend REST centralizada (`lib/services/api_service.dart` e `lib/core/api_config.dart`).
- Servi�os atualizados para opera��es de CRUD e consumo de API:
  - Clientes, Fornecedores, Materiais, Entradas, Sa�das, Estoque, Relat�rios (pasta `lib/services/`).
- Menu e navega��o aprimorados com op��o de logout (`lib/screens/menu_screen.dart`).
- Novas depend�ncias e melhorias de UI/UX:
  - `http`, `intl`, `provider`, `flutter_localizations`, `mask_text_input_formatter`, `google_fonts`, `sliding_up_panel`, `shared_preferences`.
- Diversas corre��es e ajustes de estabilidade.

## Notas da vers�o 1.1
- Fluxo de autentica��o com tela de login e registro, integra��o com API e armazenamento local da sess�o.
- Menu principal redesenhado com atalhos para materiais, parceiros, estoque, entradas, sa�das e relat�rios.
- CRUD completos para materiais, fornecedores e clientes, com valida��es de CPF/CNPJ e telefone.
- Telas de formul�rio e listagem para entradas e sa�das de materiais totalmente conectadas ao backend.
- Consultas de estoque e relat�rios com filtro por per�odo e exibi��o de totais de entrada, sa�da e saldo.
- Camada de servi�os HTTP centralizada (`ApiService`) e modelos tipados para todas as entidades.
- Utilit�rios para formata��o din�mica de CPF/CNPJ e valida��es reutiliz�veis de campos.
- Depend�ncias: http, intl, provider, flutter_localizations, mask_text_input_formatter, google_fonts, sliding_up_panel, shared_preferences.

## Cloudflare Tunnel (dom�nio fixo)

Permite expor seu backend local em um subdom�nio p�blico. Exemplo com o t�nel `gaudioso-api` e o host `api.gaudiosoreciclagens.com.br`.

- Pr�-requisitos: conta Cloudflare e `cloudflared` instalado.
- Criar e apontar DNS:
  - `cloudflared tunnel login`
  - `cloudflared tunnel create gaudioso-api`
  - `cloudflared tunnel route dns gaudioso-api api.gaudiosoreciclagens.com.br`
- Configura��o local (Windows): crie `C:\\Users\\vitor\\.cloudflared\\config.yml` com:

```
tunnel: a6cd0133-a03a-4c2a-a5c0-da02e5794c7e
credentials-file: C:\\Users\\vitor\\.cloudflared\\a6cd0133-a03a-4c2a-a5c0-da02e5794c7e.json

ingress:
  - hostname: api.gaudiosoreciclagens.com.br
    service: http://localhost:8080
  - service: http_status:404
```

- Executar o t�nel: `cloudflared tunnel run gaudioso-api`
- Verificar: `cloudflared tunnel info gaudioso-api` e `cloudflared tunnel list`

Observa��o: ajuste `service:` para a porta/host do seu backend, se necess�rio (ex.: `http://127.0.0.1:8081`).

## Build de release (Android)
- Atualize a vers�o em `pubspec.yaml` (j� em `1.2.1+3`).
- Gere APK: `flutter build apk --release`
- Ou AppBundle: `flutter build appbundle --release`

---

Para d�vidas ou problemas, abra uma issue no reposit�rio.
