#include <mex.hpp>
#include <mexAdapter.hpp>
#include <MatlabDataArray.hpp>

#include <queue>


namespace DijkstraPairs
{
    
template<typename real>
struct Vec3
{
    real x;
    real y;
    real z;

    Vec3(real x, real y, real z) : x(x), y(y), z(z) { }
    Vec3(const real* v) : x(v[0]), y(v[1]), z(v[2]) { }
    Vec3(const DijkstraPairs::Vec3<real>& V) : x(V.x), y(V.y), z(V.z) { }

    real dist2(const DijkstraPairs::Vec3<real>& V) const
    {
        double xx = x - V.x;
        double yy = y - V.y;
        double zz = z - V.z;
        return xx * xx + yy * yy + zz * zz;
    }

    real dist(const DijkstraPairs::Vec3<real>& V) const { return std::sqrt(dist2(V)); }
};


template<typename real>
class Graph
{
private:
    std::vector<DijkstraPairs::Vec3<real>> m_Pos;
    std::vector<std::vector<std::pair<int, real>>> m_Edges;

public:
    Graph(const real* vdata, int nv, const int* edata, int ne)
    {
        m_Pos.reserve(nv);
        for (int i = 0; i < nv; ++i)
            m_Pos.emplace_back(vdata + 3 * i);

        m_Edges.resize(nv);
        for (int i = 0; i < nv; ++i)
            m_Edges[i].reserve(20);
        
        for (int i = 0; i < ne; ++i)
        {
            real d = m_Pos[edata[2 * i]].dist(m_Pos[edata[2 * i + 1]]);
            m_Edges[edata[2 * i]].emplace_back(edata[2 * i + 1], d);
            m_Edges[edata[2 * i + 1]].emplace_back(edata[2 * i], d);
        }
    }
    ~Graph() { }

    real Distance(int i, int j)
    {
        std::vector<real> dists;
        dists.resize(m_Pos.size(), std::numeric_limits<real>::infinity());

        std::priority_queue<std::pair<real, int>, std::vector<std::pair<real, int>>, std::greater<std::pair<real, int>>> pq;
        dists[i] = 0.0;
        pq.emplace(dists[i], i);
        while (!pq.empty())
        {
            auto cur = pq.top();
            pq.pop();

            if (cur.second == j)
                return cur.first;

            int nadj = m_Edges[cur.second].size();
            for (int kk = 0; kk < nadj; ++kk)
            {
                int k = m_Edges[cur.second][kk].first;
                real w = m_Edges[cur.second][kk].second;
                w += dists[cur.second];
                if (dists[k] <= w)
                    continue;
                dists[k] = w;
                pq.emplace(w, k);
            }
        }

        return dists[j];
    }
};


} // namespace DijkstraPairs





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
                                { factory.createScalar("Function needs three input matrices.") }
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
        if (inputs[1].getDimensions().size() != 2 && inputs[1].getDimensions()[0] != 2)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be a 2-by-N 2D matrix.") }
                             ));
        }

        if (inputs[1].getType() != matlab::data::ArrayType::INT32 && inputs[1].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be int32.") }
                             ));
        }

        // Third input must be a 2-rows int matrix
        if (inputs[2].getDimensions().size() != 2 && inputs[2].getDimensions()[0] != 2)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be a 2-by-N 2D matrix.") }
                             ));
        }

        if (inputs[2].getType() != matlab::data::ArrayType::INT32 && inputs[2].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be int32.") }
                             ));
        }

        // Function has exactly one output
        if (outputs.size() != 1)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function has exactly one output.") }
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
        const int* edges = getDataPtr<int>(inputs[1]);
        const int* pairs = getDataPtr<int>(inputs[2]);

        // Single or double?
        if (inputs[0].getType() == matlab::data::ArrayType::DOUBLE)
        {
            const double* verts = getDataPtr<double>(inputs[0]);
            DijkstraPairs::Graph<double> G(verts, inputs[0].getDimensions()[1], edges, inputs[1].getDimensions()[1]);

            unsigned long long npairs = inputs[2].getDimensions()[1];
            outputs[0] = factory.createArray<double>(matlab::data::ArrayDimensions({ npairs, 1 }));
            for (unsigned long long i = 0; i < npairs; ++i)
                outputs[0][i] = G.Distance(pairs[2 * i], pairs[2 * i + 1]);
        }
        else
        {
            const float* verts = getDataPtr<float>(inputs[0]);
            DijkstraPairs::Graph<float> G(verts, inputs[0].getDimensions()[1], edges, inputs[1].getDimensions()[1]);

            unsigned long long npairs = inputs[2].getDimensions()[1];
            outputs[0] = factory.createArray<float>(matlab::data::ArrayDimensions({ npairs, 1 }));
            for (unsigned long long i = 0; i < npairs; ++i)
                outputs[0][i] = G.Distance(pairs[2 * i], pairs[2 * i + 1]);
        }
    }
};