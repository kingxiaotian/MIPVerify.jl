using MIPVerify: ConvolutionLayerParameters, SoftmaxParameters, FullyConnectedLayerParameters
using MIPVerify: StandardNeuralNetParameters
using MIPVerify: PerturbationParameters, AdditivePerturbationParameters, BlurPerturbationParameters
using MIPVerify.IntegrationTestHelpers: batch_test_adversarial_example
using Base.Test

@testset "Conv + FC + Softmax" begin

### Parameters for neural net
batch = 1
in1_height = 8
in1_width = 8
stride1_height = 2
stride1_width = 2
strides1 = (1, stride1_height, stride1_width, 1)
pooled1_height = round(Int, in1_height/stride1_height, RoundUp)
pooled1_width = round(Int, in1_width/stride1_width, RoundUp)
in1_channels = 1
filter1_height = 2
filter1_width = 2
out1_channels = 2

A_height = 5
A_width = pooled1_height*pooled1_width*out1_channels

B_height = 3
B_width = A_height

srand(5)
input_size = (batch, in1_height, in1_width, in1_channels)
x0 = rand(input_size)

conv1params = ConvolutionLayerParameters(
    rand(filter1_height, filter1_width, in1_channels, out1_channels)*2-1,
    rand(out1_channels)*2-1,
    strides1
)

fc1params = FullyConnectedLayerParameters(
    rand(-10:10, A_width, A_height),
    rand(-10:10, A_height)
)

softmaxparams = SoftmaxParameters(
    rand(B_width, B_height)*2-1,
    rand(B_height)*2-1
)

nnparams = StandardNeuralNetParameters(
    [conv1params], 
    [fc1params], 
    softmaxparams,
    "tests.integration.generated_weights.conv+fc+softmax"
)

expected_objective_values::Dict{Int, Dict{PerturbationParameters, Dict{Real, Dict{Real, Float64}}}} = Dict(
    1 => Dict(
        BlurPerturbationParameters((5, 5)) => Dict(
            1 => Dict(
                0 => 0
            ),
            Inf => Dict(
                0 => 0
            ),
        )
    ),
    2 => Dict(
        AdditivePerturbationParameters() => Dict(
            1 => Dict(
                0 => 2.9826560354715803,
                0.1 => 3.0346542633968334,
                1 => 3.5738646877222147
            ),
            Inf => Dict(
                0 => 0.23563145790531903,
                0.1 => 0.24012407765320404,
                1 => 0.28536464231819064
            )
        ),
        BlurPerturbationParameters((5, 5)) => Dict(
            1 => Dict(
                0 => NaN,
            ),
            Inf => Dict(
                0 => NaN,
            )

        )
    ),
    3 => Dict(
        BlurPerturbationParameters((5, 5)) => Dict(
            1 => Dict(
                0 => 0.26148313171566834,
                1 => 0.826241509034785,
                10 => NaN
            ),
            Inf => Dict(
                0 => 0.0105534113962751,
                1 => 0.03696859980011553,
                10 => NaN
            )

        )
    )
)

batch_test_adversarial_example(nnparams, x0, expected_objective_values)

end