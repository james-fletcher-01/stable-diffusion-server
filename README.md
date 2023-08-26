# Stable Diffusion Server

Apple's [ml-stable-diffusion](https://github.com/apple/ml-stable-diffusion) library comes with a sample project, which provides a CLI executable for testing the functionality of the library. The tool accepts a large number of arguments for customising its behaviour, which exposes a significant amount of functionality from the library. This makes the tool useful in and of itself for general purposes, without needing to write your own code to use the functionality of the library.

Unfortunately, being a simple CLI executable, the tool runs once and exits, which means you need to re-execute the entire process for every image you want to generate. This includes loading the Core ML models on every execution, which can be time consuming.

**Stable Diffusion Server** solves this issue by creating a socket server for generating images. It exposes all of the same functionality as Apple's sample tool, but in the form of a server that performs the initial setup once, and then accepts connections over a Unix Domain Socket for generating images. This makes it possible to use the features of the stable diffusion library from other processes.

The socket server is built using [swift-nio](https://github.com/apple/swift-nio), and managed by [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle). The CLI is built using [swift-argument-parser](https://github.com/apple/swift-argument-parser). The image generation code is taken from Apple's sample project, almost entirely unmodified, other than minor modifications to fit it into the structure of this project.

## Starting the Server

See below for the CLI options. The image generation options are identical to Apple's sample project. See the library documentation for more information.

    USAGE: StableDiffusionServer [<options>] --socket-path <socket-path> --resource-path <resource-path> --output-path <output-path>

    SOCKET OPTIONS:

        -s, --socket-path <socket-path>
            The Unix domain socket path to bind to.
            The socket must not exist, it will be created by the system.

        -t, --number-threads <number-threads>
            The number of threads to use when listening for requests.
            A value of higher than one allows requests to be handled simultaneously, but may slow down each request.
            By default, creates a thread for each available CPU core.

    IMAGE GENERATION OPTIONS:

        -r, --resource-path <resource-path>
            Path to stable diffusion resources.
            The resource directory should contain
            - *compiled* models: {TextEncoder,Unet,VAEDecoder}.mlmodelc
            - tokenizer info: vocab.json, merges.txt

        -o, --output-path <output-path>
            Output path

        --xl
            The resources correspond to a Stable Diffusion XL model

        --strength <strength>
            Strength for image2image. (default: 0.5)

        --step-count <step-count>
            Number of diffusion steps to perform (default: 50)

        --seed <seed>
            Random seed (default: 517607856)

        --guidance-scale <guidance-scale>
            Controls the influence of the text prompt on sampling process (0=random images) (default: 7.5)

        --compute-units <compute-units>
            Compute units to load model with {all,cpuOnly,cpuAndGPU,cpuAndNeuralEngine} (default: all)

        --scheduler <scheduler>
            Scheduler to use, one of {pndm, dpmpp} (default: pndm)

        --rng <rng>
            Random number generator to use, one of {numpy, torch} (default: numpy)

        --controlnet <controlnet>
            ControlNet models used in image generation (enter file names in Resources/controlnet without extension)

        --controlnet-inputs <controlnet-inputs>
            image for each controlNet model (corresponding to the same order as --controlnet)

        --disable-safety
            Disable safety checking

        --reduce-memory
            Reduce memory usage

        --use-multilingual-text-encoder
            Use system multilingual NLContextualEmbedding as encoder model

        --script <script>
            The natural language script for the multilingual contextual embedding (default: latin)

    OPTIONS:

        --version Show the version.

        -h, --help  Show help information.

## Image Generation

The socket accepts a JSON string containing an object with the following keys:
- **prompt:** Input string prompt
- **negative-prompt:** Input string negative prompt
- **image:** Path to starting image (optional).
- **image-count:** Number of images to sample / generate. Defaults to 1.
- **save-every:** How often to save samples at intermediate steps. Set to 0 to only save the final sample. Defaults to 0.

These options are identical to  the corresponding CLI options in Apple's sample project. See the library documentation for more information.

If the input can't be parsed as a JSON string, it is assumed to be a plain string containing only a prompt. This means that you can generate a single image simply by passing the prompt as a string, without having to generate a JSON string.

## Response

The response is a JSON string containing an array for each generated image, with each element consisting of an array of image names for each sample image, which can be found in the output path. The last element in each array is the final generated image.

    [
        [
            "2C440978-DBD9-4C4E-9DCA-66A2B9DB609B.1.1.png",
            "2C440978-DBD9-4C4E-9DCA-66A2B9DB609B.1.2.png",
            "2C440978-DBD9-4C4E-9DCA-66A2B9DB609B.1.final.png"
        ],
        [
            "2C440978-DBD9-4C4E-9DCA-66A2B9DB609B.2.1.png",
            "2C440978-DBD9-4C4E-9DCA-66A2B9DB609B.2.2.png",
            "2C440978-DBD9-4C4E-9DCA-66A2B9DB609B.2.final.png"
        ]
    ]
