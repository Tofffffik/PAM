# CarPool

Мобильное приложение студенческого райдшеринга: водитель публикует маршрут с
временем выезда, числом мест и ценой, пассажиры бронируют места.

**Стек:** Flutter (клиент), .NET + Entity Framework Core (backend), JWT.

## Документы

| Файл | О чём |
|------|-------|
| [SPEC.md](./SPEC.md) | Экраны, модель данных, endpoint-ы, правила валидации |
| [DESIGN.md](./DESIGN.md) | Цвета, типографика, компоненты, тексты интерфейса |
| [PLAN.md](./PLAN.md) | Порядок разработки по этапам L1–L6 |

## Запуск

Приложение:

```bash
cd app
flutter pub get
flutter run
```

Backend:

```bash
cd backend
dotnet restore
dotnet ef database update
dotnet run
```

Базовый URL API задаётся в конфигурации приложения; Swagger UI доступен на
корне backend-а в режиме разработки.

## Структура

```
app/      Flutter-приложение
backend/  ASP.NET Core API
```
