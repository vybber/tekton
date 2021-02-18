docker run \
    -ti --rm -v "$HOME"/dotnetexample:/workspace \
    -v "$HOME"/.docker/config.json:/kaniko/.docker/config.json:ro \
    gcr.io/kaniko-project/executor:latest \
    --dockerfil=/workspace/helloword/helloword/Dockerfile \
    --context=/workspace/helloword/helloword \
    --destination=dockerexample \
    --verbosity=trace