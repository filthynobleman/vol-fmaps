#include <mex.hpp>
#include <mexAdapter.hpp>
#include <MatlabDataArray.hpp>

#include <Eigen/Dense>
#include <igl/point_mesh_squared_distance.h>

namespace NearestSurfPoint
{
    
typedef Eigen::Matrix<int, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> RMMatI;
typedef Eigen::Matrix<float, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> RMMatF;
typedef Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> RMMatD;

typedef Eigen::Matrix<int, Eigen::Dynamic, Eigen::Dynamic, Eigen::ColMajor> CMMatI;
typedef Eigen::Matrix<float, Eigen::Dynamic, Eigen::Dynamic, Eigen::ColMajor> CMMatF;
typedef Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::ColMajor> CMMatD;

} // namespace NearestSurfPoint


class MexFunction : public matlab::mex::Function
{
public:
    void check_args(matlab::mex::ArgumentList outputs,
                    matlab::mex::ArgumentList inputs)
    {
        std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

        matlab::data::ArrayFactory factory;

        // Three inputs are needed
        if (inputs.size() < 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function needs three inputs.") }
                             ));
        }

        // First input must be a three-rows single or double matrix
        if (inputs[0].getDimensions().size() != 2 && inputs[0].getDimensions()[0] != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("First input must be a 3-by-N 2D matrix.") }
                             ));
        }

        if (inputs[0].getType() != matlab::data::ArrayType::DOUBLE && inputs[0].getType() != matlab::data::ArrayType::SINGLE)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("First input must be single or double.") }
                             ));
        }

        // Second input must be a 2-rows int matrix
        if (inputs[1].getDimensions().size() != 2 && inputs[1].getDimensions()[0] != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be a 3-by-N 2D matrix.") }
                             ));
        }

        if (inputs[1].getType() != matlab::data::ArrayType::DOUBLE && inputs[1].getType() != matlab::data::ArrayType::SINGLE)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be single or double.") }
                             ));
        }

        // Third input must be a 2-rows int matrix
        if (inputs[2].getDimensions().size() != 2 && inputs[2].getDimensions()[0] != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be a 3-by-N matrix.") }
                             ));
        }

        if (inputs[2].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be int32.") }
                             ));
        }

        // Function has exactly one output
        if (outputs.size() != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function has exactly three output.") }
                             ));
        }
    }

    template<typename T>
    const T* getDataPtr(matlab::data::Array arr) 
    {
        const matlab::data::TypedArray<T> arr_t = arr;
        matlab::data::TypedIterator<const T> it(arr_t.begin());
        return it.operator->();
    }

    void operator()(matlab::mex::ArgumentList outputs,
                    matlab::mex::ArgumentList inputs)
    {
        check_args(outputs, inputs);

        matlab::data::ArrayFactory factory;

        // Retrieve indices
        const int* tris = getDataPtr<int>(inputs[2]);
        NearestSurfPoint::RMMatI T;
        T = NearestSurfPoint::RMMatI::Map(tris, inputs[2].getDimensions()[1], inputs[2].getDimensions()[0]);

        // Single or real?
        if (inputs[0].getType() == matlab::data::ArrayType::DOUBLE)
        {
            const double* v1 = getDataPtr<double>(inputs[0]);
            const double* v2 = getDataPtr<double>(inputs[1]);
            NearestSurfPoint::RMMatD V1 = NearestSurfPoint::RMMatD::Map(v1, inputs[0].getDimensions()[1], inputs[0].getDimensions()[0]);
            NearestSurfPoint::RMMatD V2 = NearestSurfPoint::RMMatD::Map(v2, inputs[1].getDimensions()[1], inputs[1].getDimensions()[0]);

            Eigen::VectorXd sqrD;
            Eigen::VectorXi I;
            NearestSurfPoint::CMMatD C;

            igl::point_mesh_squared_distance(V1, V2, T, sqrD, I, C);

            unsigned long long nqp = inputs[0].getDimensions()[1];
            outputs[0] = factory.createArray<double>(matlab::data::ArrayDimensions({ nqp, 1 }));
            outputs[1] = factory.createArray<int>(matlab::data::ArrayDimensions({ nqp, 1 }));
            outputs[2] = factory.createArray<double>(matlab::data::ArrayDimensions({ nqp, 3 }));

            int i = 0;
            for (i = 0; i < nqp; ++i)
            {
                outputs[0][i] = sqrD[i];
                outputs[1][i] = I[i];
                outputs[2][i][0] = C.array().data()[i];
            }
            for (i = 0; i < nqp; ++i)
                outputs[2][i][1] = C.array().data()[nqp + i];
            for (i = 0; i < nqp; ++i)
                outputs[2][i][2] = C.array().data()[nqp + nqp + i];
        }
        else
        {
            const float* v1 = getDataPtr<float>(inputs[0]);
            const float* v2 = getDataPtr<float>(inputs[1]);
            NearestSurfPoint::RMMatF V1 = NearestSurfPoint::RMMatF::Map(v1, inputs[0].getDimensions()[1], inputs[0].getDimensions()[0]);
            NearestSurfPoint::RMMatF V2 = NearestSurfPoint::RMMatF::Map(v2, inputs[1].getDimensions()[1], inputs[1].getDimensions()[0]);

            Eigen::VectorXf sqrD;
            Eigen::VectorXi I;
            NearestSurfPoint::CMMatF C;

            igl::point_mesh_squared_distance(V1, V2, T, sqrD, I, C);

            unsigned long long nqp = inputs[0].getDimensions()[1];
            outputs[0] = factory.createArray<float>(matlab::data::ArrayDimensions({ nqp, 1 }));
            outputs[1] = factory.createArray<int>(matlab::data::ArrayDimensions({ nqp, 1 }));
            outputs[2] = factory.createArray<float>(matlab::data::ArrayDimensions({ nqp, 3 }));

            int i = 0;
            for (i = 0; i < nqp; ++i)
            {
                outputs[0][i] = sqrD[i];
                outputs[1][i] = I[i];
                outputs[2][i] = C.array().data()[i];
            }
            nqp = 3 * nqp;
            for ( ; i < nqp; ++i)
                outputs[2][i] = C.array().data()[i];
        }
    }
};