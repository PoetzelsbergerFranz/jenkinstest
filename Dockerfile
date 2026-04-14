# Nutze das gewünschte Image als Basis
FROM mirror.gcr.io/library/tomcat:10.1-jre21-temurin-slim

# Entferne die Standard-Webapps (optional, für Sicherheit)
RUN rm -rf /usr/local/tomcat/webapps/*

# Kopiere deine Website/App in das ROOT-Verzeichnis
# Wenn es nur HTML ist, erstelle einen Ordner ROOT
COPY ./index.html /usr/local/tomcat/webapps/ROOT/index.html

# Tomcat läuft standardmäßig auf Port 8080
EXPOSE 8080