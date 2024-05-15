FROM julia:latest

WORKDIR /app


COPY Earthquakes_main.jl /app

COPY src/ /app/src/

COPY Project.toml /app
COPY Manifest.toml /app

RUN julia --project=@. -e "using Pkg; Pkg.instantiate();"

CMD ["julia", "--project=@.", "Earthquakes_main.jl"]
