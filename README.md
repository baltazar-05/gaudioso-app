# Gaudioso App

Aplicativo Flutter para gestão de reciclagem (materiais, parceiros, entradas/saídas, estoque e relatórios), com autenticação e integração a backend REST.

## Requisitos
- Flutter 3.35.6 (canal stable)
- Android toolchain configurado (SDK + licenças aceitas)
- Opcional: Visual Studio (para build Windows)

## Configuração de API
A base da API é configurável via `--dart-define`:
- Arquivo: `lib/core/api_config.dart`
- Padrão: `http://10.0.2.2:8080` (Android emulador)
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

## Build de release (Android)
- Atualize a versão em `pubspec.yaml` (já em `1.2.0+2`).
- Gere APK: `flutter build apk --release`
- Ou AppBundle: `flutter build appbundle --release`

---

Para dúvidas ou problemas, abra uma issue no repositório.
