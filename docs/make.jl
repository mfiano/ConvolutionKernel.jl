using ConvolutionKernel
using Documenter

DocMeta.setdocmeta!(ConvolutionKernel, :DocTestSetup, :(using ConvolutionKernel); recursive=true)

makedocs(;
    modules=[ConvolutionKernel],
    authors="Michael Fiano <mail@mfiano.net> and contributors",
    repo="https://github.com/mfiano/ConvolutionKernel.jl/blob/{commit}{path}#{line}",
    sitename="ConvolutionKernel.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mfiano.github.io/ConvolutionKernel.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mfiano/ConvolutionKernel.jl",
    devbranch="main",
)
