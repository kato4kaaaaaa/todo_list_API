FROM swift:6.1-focal AS builder


WORKDIR /app

# Копіюємо файли залежностей
COPY Package.swift Package.resolved ./

# Резолвимо/завантажуємо залежності
RUN swift package resolve

# Копіюємо решту коду проекту
COPY Sources ./Sources
# COPY Resources ./Resources 

# Збираємо проект в release конфігурації
COPY Tests ./Tests

RUN swift build --configuration release


FROM ubuntu:focal 

WORKDIR /app

# Встановлюємо runtime залежності
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl1.1 \
    libicu66 \
    libcurl4 \
    libpq5 \
    zlib1g \
  && rm -rf /var/lib/apt/lists/*

# Копіюємо Swift runtime бібліотеки з образу builder
COPY --from=builder /usr/lib/swift/linux/*.so* /usr/lib/swift/linux/


# Копіюємо зібраний виконуваний файл
# Ім'я "App" має відповідати .executableTarget(name: "App", ...) у Package.swift
COPY --from=builder /app/.build/release/App ./Run

# Копіюємо теку Public, якщо є
# COPY --from=builder /app/Public ./Public
# Копіюємо теку Resources, якщо є
# COPY --from=builder /app/Resources ./Resources

# Вказуємо шлях до бібліотек Swift
ENV LD_LIBRARY_PATH=/usr/lib/swift/linux:$LD_LIBRARY_PATH

EXPOSE 8080

CMD ["./Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]