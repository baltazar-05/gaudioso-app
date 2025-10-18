# Gaudioso App

Aplicativo Flutter para gestao das operacoes da Gaudioso Reciclagens.

## Versao 1.1

### Resumo das alteracoes
- Fluxo de autenticacao com tela de login e registro, integracao com API e armazenamento local da sessao.
- Menu principal redesenhado com atalhos para materiais, parceiros, estoque, entradas, saidas e relatorios.
- CRUD completos para materiais, fornecedores e clientes, com validacoes de CPF/CNPJ e telefone.
- Telas de formulario e listagem para entradas e saidas de materiais totalmente conectadas ao backend.
- Consultas de estoque e relatorios com filtro por periodo e exibicao de totais de entrada, saida e saldo.
- Camada de servicos HTTP centralizada (`ApiService`) e modelos tipados para todas as entidades manipuladas pelo app.
- Utilitarios para formatacao dinamica de CPF/CNPJ e validacoes reutilizaveis de campos.
- Novas dependencias: http, intl, provider, flutter_localizations, mask_text_input_formatter, google_fonts, sliding_up_panel e shared_preferences.
